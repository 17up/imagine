class DeviceMember
	include Mongoid::Document
	include Mongoid::Timestamps::Short

	field :uuid, type: String
	field :token, type: String
	field :platform, type: String
	field :name, type: String
	field :app, type: String

	has_many :u_words, dependent: :destroy
	belongs_to :member

	class << self
		def auth_device(uuid)
			self.where(uuid: uuid).first
		end

		def generate(app,opts = {})
			defaults = {
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

	def as_json
		{
			_id: id.to_s,
			app: app
		}
	end

	rails_admin do
		field :platform
		field :name
		field :app
		field :member
		field :uuid
		field :u_words do
			pretty_value do
				value.length
			end
		end
		field :c_at
	end

end
