class Song
  include Mongoid::Document
  include Concerns::Likeable

  field :lyrics
	field :artist
	field :album
	field :title
	field :format
	field :u_at, type: DateTime

	validates :title, uniqueness: true, presence: true
	validates :lyrics, presence: true

	after_save :update_time
	after_destroy :clear_data

	AUDIO_URL = "/system/audios/song/"
	AUDIO_PATH = "#{Rails.root}/public" + AUDIO_URL

	def update_time
    self.set(:u_at,Time.current)
  end

	def audio_path
		AUDIO_PATH + "#{_id}/#{$config[:name]}." + format if format
	end

	def audio_url
		AUDIO_URL + "#{_id}/#{$config[:name]}." + format if format
	end

	def as_json
		ext = {
			url: audio_url,
			liked_count: liked_count,
			_id: id.to_s
		}
		super(only: [:lyrics,:artist,:title]).merge(ext)
	end

	def clear_data
    `rm -rf #{AUDIO_PATH + _id}`
  end 

	rails_admin do 
		list do
	  	field :title
	  	field :artist
	  	field :album
	  	field :format
	  	field :lyrics, :text
	  end
	  show do 
      configure :liked_member_ids do 
      	label "liked members"
        pretty_value do 
        	Member.where(:_id.in => value).collect(&:name).join(",")
        end
      end
    end
	end
end
