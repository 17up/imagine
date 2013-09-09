class SongsController < ApplicationController
	before_filter :authenticate_member!

	def create
		attrs = params.slice(:artist,:title,:album,:lyrics)
		if song = Song.where(title: attrs['title']).first
			song.update_attributes(attrs)
		else
			song = Song.create(attrs)
		end
		render_json 0,"ok",song._id
	end

	def upload
		song = Song.find(params[:_id])
		@store_path = Song::AUDIO_PATH + "#{song._id}"
		unless File.exist?(@store_path)
			`mkdir -p #{@store_path}`
		end
		file = params[:audio]
		format = file.original_filename.split(".")[-1].downcase
		song.update_attribute(:format,format)
		File.open(song.audio_path,"wb"){|f| f.write file.read}
		if File.exist? song.audio_path
			render_json 0,"upload success",song.as_json
		else
			render_json -1,"fail"
		end
	end

end
