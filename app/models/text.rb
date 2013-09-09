class Text
	include Mongoid::Document

	field :lang
	field :content
	field :tags, type: Array

	scope :en, -> {where(lang: nil)}

end
