class DeviceMember
	include Mongoid::Document
	include Mongoid::Timestamps::Short

	field :token, type: String
	field :banner, type: String
	field :name, type: String
	field :app, type: String

	# 学币
	field :gems, type: Integer, default: 0

	has_many :u_words, dependent: :destroy

	class << self
		def auth_device(device_token)
			self.where(token: device_token).first
		end

		def generate(device_token,app,opts = {})
			defaults = {
				token: device_token,
				app: app
			}
			member = self.create(defaults.merge(opts))
		end
	end

	# uword
	def has_u_word(wid)
		UWord.where(device_member_id: self.id,word_id: wid).first
	end

	def has_word_audio(wid)
		a = has_u_word(wid)
		a&&a.audio
	end

	def has_word_image(wid,opts = {})
		a = has_u_word(wid)
		if opts[:origin]
			a&&a.origin_image_url
		else
			a&&a.image
		end
	end

end
