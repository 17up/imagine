class UWord
	include Mongoid::Document
	include Mongoid::Timestamps::Short

	field :img_size, type: Hash
	field :desc
	field :geo, type: Array

	belongs_to :device_member
	belongs_to :word

	validates :device_member_id, presence: true, uniqueness: {scope: :word_id}

	IMAGE_URL = "/system/images/u_word/"
	IMAGE_PATH = "#{Rails.root}/public" + IMAGE_URL
	IMAGE_SIZE_LIMIT = 3*1000*1000 #2m
	IMAGE_WIDTH = 640
	# iphone 5
	IMAGE_HEIGHT = 857

	AUDIO_URL = "/system/audios/u_word/"
	AUDIO_PATH = "#{Rails.root}/public" + AUDIO_URL

	scope :has_image, -> {where(:img_size.exists => true)}

	def title
		word.title
	end

	def make_image(file)
		dir = IMAGE_PATH + "#{_id}"
		unless File.exist?(dir)
			`mkdir -p #{dir}`
			device_member.gems += 1
			device_member.save
		end
		h = Image::Convert.new(file,outfile: image_path).draw(word.image_path,original: origin_image_path)
		self.img_size = {width: IMAGE_WIDTH,height: h}
		self
	end

	def image_path
		IMAGE_PATH + "#{_id}/#{$config[:name]}.jpg"
	end

	def image_url
		IMAGE_URL + "#{_id}/#{$config[:name]}.jpg"
	end

	def origin_image_path
		IMAGE_PATH + "#{_id}/#{$config[:name]}_origin.jpg"
	end

	def origin_image_url
		IMAGE_URL + "#{_id}/#{$config[:name]}_origin.jpg"
	end

	def audio_path
		AUDIO_PATH + "#{_id}/#{$config[:name]}.ogg"
	end

	def audio_url
		AUDIO_URL + "#{_id}/#{$config[:name]}.ogg"
	end

	def audio
		has_audio&&audio_url
	end

	def image
		img_size&&image_url
	end

	def validate_upload_image(file,type)
		type.scan(/(jpeg|png|gif)/).any? and File.size(file) < IMAGE_SIZE_LIMIT
	end

	private
	def has_audio
		return File.exist?(audio_path)
	end

end
