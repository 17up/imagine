class MembersController < ApplicationController
	before_filter :authenticate_member!,except: [:show,:timeline]

	# page
	def index
		set_seo_meta(nil)
	end

	# api get
	def dashboard
		data = {
			quote: Eva::Iquote.new(current_member).single,
			courses: Eva::Course.new(current_member).list,
			song: Eva::Song.new(current_member).single,
			game: Eva::Game.new(current_member).list
		}

		unless current_member.is_member?
			guides = YAML.load_file(Rails.root.join("doc","guide.yml")).fetch("guide")
			data.merge!(guides: guides)
		end
		render_json 0,'ok',data
	end

	# api get
	def account
		if current_member.is_member?
			@providers = Authorization::PROVIDERS.map do |p|
				provider = current_member.has_provider?(p)
				{
					provider: p,
					has_bind: provider && provider.check_expired,
					omniauth_url: member_omniauth_authorize_path(p)
				}
			end
			data = current_member.as_json.merge(providers: @providers)
			render_json 0,'ok',data
		else
			render_json -1,"u are not member"
		end
	end

	# get provider info
	# @params :provider
	def provider
		p = current_member.has_provider?(params[:provider])
		render_json 0,"ok",p.as_json
	end

	# get current member profile
	def profile
		render_json 0,"ok",current_member.as_profile
	end

	# api get
	def friend
		render_json 0,'ok'
	end

	# api get
	def teach
		if current_member.is_teacher?
			@courses = current_member.courses.collect(&:as_json)
			render_json 0,'ok',@courses
		else
			render_json -1,"u are not teacher"
		end
	end

	# page
	def show
		role_ok = Member::ROLE.include?(params[:role])
		if role_ok and @user = Member.send(params[:role]).where(uid: params[:uid]).first
			set_seo_meta(@user.name)
		else
			redirect_to "/not_found"
		end
	end

	# api get
	def timeline
		member = Member.find(params[:_id])
		data = {}
		# 是好友关系能看到收藏
		if current_member
			if (current_member.id == member.id) || current_member.friend_ids.include?(member.id)
				songs_liked = Song.where(:_id.in => member.song_ids).collect(&:as_json)
				data.merge!(songs_liked: songs_liked)
			end
		end

		render_json 0,"ok",data
	end

	# 充值
	# post
	def add_gem

	end

	# post
	def upload_avatar
		file = params[:image].tempfile.path
		type = params[:image].content_type
		if current_member.validate_upload_avatar(file,type)
			current_member.save_avatar(file)
			@avatar = current_member.avatar + "?#{Time.now.to_i}"
			render_json 0,t('flash.notice.avatar'),@avatar
		else
			render_json -1,t('flash.error.avatar')
		end

	end

	# post
	def upload_audio
		file = params[:file]
		@store_path = Member::AUDIO_PATH + current_member._id
		@audio_path = current_member.audio_path(params[:_id])
		unless File.exist?(@store_path)
			`mkdir -p #{@store_path}`
		end
		# 压缩成 ogg
		`oggenc -q 4 #{file.tempfile.path} -o #{@audio_path}`
		render_json 0,"ok"
	end

	# set uid
	# post
	def update
		if params[:uid].blank?
			render_json -3,t('flash.error.blank')
			return
		end
		if Member.u.where(uid: params[:uid]).first
			render_json -2,t('flash.error.uid')
			return
		end
		if current_member.init_by(params[:uid])
			render_json 0,"ok"
		else
			render_json -1,t('flash.error.uid_format')
		end
	end

	# invite
	# @msg
	# @course_id
	# @style common / teach
	def send_invite
		avaliable_providers = current_member.authorizations.collect(&:provider) & %w{weibo twitter}
		if avaliable_providers.any?
			cid = params[:course_id]
			avaliable_providers.each do |provider|
				@invite = current_member.invites.create(provider: provider,course_id: cid)
				message = params[:msg].gsub(/\s+/,' ') + " #{$config[:host]}/invites/#{@invite.id}"
				HardWorker::SendInviteJob.perform_async(message,current_member.has_provider?(provider)._id.to_s)
			end
			render_json 0,"ok"
		else
			render_json -1,"haven't any avaliable providers"
		end

	end

	# 向已存在好友发起邀请
	# @_id
	# @course_id
	def invite_friend
		@friend = Member.find(params[:_id])
		if @friend.has_checkin?(params[:course_id])
			render_json -1,"already checkin"
		else
			current_member.invites.create(target: @friend._id,course_id: params[:course_id])
			render_json 0,"ok"
		end
	end

	# like
	# @obj [Song,Quote]
	# @_id
	def like
		valiable_obj = %w{Song Quote}
		if valiable_obj.include? params[:obj]
			obj = eval(params[:obj]).find(params[:_id])
			obj.liked_by(current_member)
			render_json 0,"ok",obj.liked_count
		else
			render_json -1,"invalue"
		end

	end

end
