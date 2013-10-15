class Word
	include Mongoid::Document

	field :title
	field :content
	field :raw_content, type: Hash
	field :pos, type: Array, default: []
	field :lang
	field :family, type: Array, default: []
	field :synset, type: Array, default: []

	has_many :u_words

	scope :en, -> {where(lang: nil)}

	validates :title, presence: true, uniqueness: true
	IMAGE_URL = "/system/images/word/"
	IMAGE_PATH = "#{Rails.root}/public"+IMAGE_URL
	after_create :draw

	class << self
		def pos_by(pos,match_any = true)
			if match_any
				self.any_in(pos: pos.split(","))
			else
				self.all_in(pos: pos.split(","))
			end
		end
	end

	def source_voice
		$dict_source[:english_v] + URI.encode(self.title)
	end

	# draw word
	def image_path
		IMAGE_PATH + self.title.parameterize.underscore + "/w.png"
	end

	def image_url
		IMAGE_URL + self.title.parameterize.underscore + "/w.png"
	end

	def image
		u_words.any? && u_words.last.image
	end

	def draw
		dir = IMAGE_PATH + self.title.parameterize.underscore
		unless File.exist?(dir)
			`mkdir -p #{dir}`
		end
		opts = {
			text: title,
			type: 2,
			word_path: image_path
		}
		Image::Convert.draw_word(opts)
	end

	def as_json
		ext = {
			_id: id.to_s
		}
		super(only: [:title,:content,:raw_content,:pos,:synset,:family]).merge(ext)
	end

	rails_admin do
		field :title
		field :content
		field :raw_content
		field :pos
		field :family
		field :synset
	end

	index({ title: 1})
end
