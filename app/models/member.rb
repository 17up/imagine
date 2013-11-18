class Member
	include Mongoid::Document
	include Mongoid::Timestamps::Short

	devise :database_authenticatable,:token_authenticatable,
		:recoverable, :trackable, :validatable,
		:omniauthable, omniauth_providers: [:weibo,:twitter,:github,:tumblr,:instagram,:youtube,:qq_connect]

	before_save :ensure_authentication_token
	## Database authenticatable
	field :email,              type: String, default: ""
	field :encrypted_password, type: String, default: ""

	## Recoverable
	field :reset_password_token,   type: String
	field :reset_password_sent_at, type: Time

	## Trackable
	field :sign_in_count,      type: Integer, default: 0
	field :current_sign_in_at, type: Time
	field :last_sign_in_at,    type: Time
	field :current_sign_in_ip, type: String
	field :last_sign_in_ip,    type: String

	## Token authenticatable
	field :authentication_token, type: String

	field :role
	field :uid
	# 学币
	field :gems, type: Integer, default: 0
	# 学分
	field :score, type: Integer, default: 0
	field :friend_ids, type: Array, default: []
	# 收藏
	field :quote_ids, type: Array, default: []
	field :song_ids, type: Array, default: []

	has_many :authorizations, dependent: :destroy
	has_many :courses
	has_many :invites, dependent: :destroy
	has_many :device_members

	embeds_many :course_grades
	accepts_nested_attributes_for :course_grades

	validates :uid, uniqueness: true,
		allow_blank: true,
		length: {in: 2..20 },
		format: {with: /^[A-Za-z0-9_]+$/ ,multiline: true}

	after_destroy :clear_data

	AVATAR_URL = "/system/images/member/"
	AVATAR_PATH = "#{Rails.root}/public" + AVATAR_URL

	AUDIO_URL = "/system/audios/member/"
	AUDIO_PATH = "#{Rails.root}/public" + AUDIO_URL

	AVATAR_SIZE_LIMIT = 3000*1000 #3m
	THUMB_SIZE = 120
	DEFAULT_GEMS = 10
	## role 用户组别
	ROLE = %w{a u t}
	# nil 三无用户，被清理对象
	scope :x, -> {where(role: nil)}
	ROLE.each do |r|
		scope r.to_sym, -> {where(role: r)}
	end

	class << self
		def authorize(token)
			self.where(authentication_token: token).first
		end

		def generate(prefix = Utils.rand_passwd(7,number: true))
			email = prefix + "@" + $config[:domain]
			passwd = Utils.rand_passwd(8)
			user = Member.new(
				email: email,
				password: passwd,
				password_confirmation: passwd
			)
			if user.save!
				user
			else
				self.generate(prefix + "v")
			end
		end
	end

	def admin?
		self.role == "a"
	end

	def is_teacher?
		self.role == "t" || admin?
	end

	def is_member?
		role.present?
	end

	def checked_courses
		cids = course_grades.collect(&:course_id)
		Course.where(:_id.in => cids)
	end

	def checkin(course)
		unless has_checkin?(course.id)
			gems = self.gems - course.price
			return false if gems < 0
			self.course_grades << CourseGrade.new(course_id: course.id)
			self.set(gems: gems)
		end
	end

	def invited_courses
		cids = Invite.inside.where(target: self._id).collect(&:course_id).uniq
		Course.where(:_id.in => cids)
	end

	def has_checkin?(course_id)
		course_grades.where(course_id: course_id).any?
	end

	# profile
	def member_path
		"#{role}/#{uid}"
	end

	def avatar
		File.exist?(AVATAR_PATH + avatar_name) ? (AVATAR_URL + avatar_name) : "icon/avatar.jpg"
	end

	def avatar_name
		"#{_id}/#{c_at.to_i}.jpg"
	end

	def validate_upload_avatar(file,type)
		type.scan(/(jpeg|png|gif)/).any? and File.size(file) < AVATAR_SIZE_LIMIT
	end

	# audio message
	def audio_path(ts)
		AUDIO_PATH + "#{_id}/#{ts}.ogg"
	end

	def audio_url(ts)
		AUDIO_URL + "#{_id}/#{ts}.ogg"
	end

	def name
		p = self.authorizations.first
		p ? p.user_name : $config[:author]
	end

	def has_provider?(p)
		self.authorizations.where(provider: p).first
	end

	def save_avatar(file_path)
		`mkdir -p #{AVATAR_PATH + _id}`
		Image::Convert.square_thumb(file_path,THUMB_SIZE).write(AVATAR_PATH + avatar_name)
	end

	def init_by(uid)
		data = { uid: uid, role: "u", gems: DEFAULT_GEMS, email: "#{uid}@#{$config[:domain]}" }
		self.update_attributes(data)
	end

	# 受到邀请注册
	def invited_by(invite)
		owner = invite.member
		owner.friend_ids << self._id
		owner.gems += 2
		owner.save
		# 当前被邀请用户免费登记受邀课程,并加好友
		# 通知受邀者成功接受了多少个邀请，并新增了多少好友
		self.friend_ids << owner._id
		self.course_grades << CourseGrade.new(course_id: invite.course_id)
		self.save
	end

	def bind_service(omniauth, expires_time)
		self.authorizations.create!(
			provider:     omniauth.provider,
			uid:          omniauth.uid,
			token: omniauth.credentials.token,
			secret: omniauth.credentials.secret,
			info: omniauth.info,
			expired_at: expires_time,
			refresh_token: omniauth.credentials.refresh_token
		)
	end

	def clear_data
		`rm -rf #{AVATAR_PATH + _id.to_s}`
	end

	def as_json
		ext = {
			member_path: member_path,
			grades: course_grades.length,
			friends: friend_ids.length
		}
		super(only: [:role,:uid,:score]).merge(ext)
	end

	def as_profile
		{
			_id: id.to_s,
			avatar: avatar,
			name: name,
			member_path: member_path,
			gems: gems,
			is_member: is_member?,
			is_teacher: is_teacher?
		}
	end

	rails_admin do
		field :email do
			label "Avatar"
			pretty_value do
				bindings[:view].image_tag(bindings[:object].avatar)
			end
			column_width 55
		end
		field :uid
		field :role
		field :gems
		field :c_at
		field :last_sign_in_ip do
			label "IP"
		end
		field :authorizations
		field :current_sign_in_at do
			label "Time"
		end
		field :friend_ids do
			label "Frds"
			pretty_value do
				value.length
			end
		end
	end

	#mongo index
	index({uid: 1},{ unique: true })
end
