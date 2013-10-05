require 'helpers'

class Icard < Grape::API
	prefix 'api'
	format :json

	helpers APIHelpers

	before do
		authenticated_device?
	end

	resource :members do
		desc "register or login"
		get "/" do
			unless current_device
				current_device = DeviceMember.generate("icard",params.slice(:uuid,:name,:platform))
			end
			render_json 0,"ok",current_device.as_json
		end
	end

	resource :cards do
		desc "get u_words"
		get "/" do
			data = Eva::Icard.new(current_device).list
			render_json 0, "ok", data
		end

		desc "get u_word collection by same word id"
		get :collection do
			word = Word.find(params[:id])
			data = word.u_words.map{|w| w.image}
			render_json 0,"ok", data
		end

		desc "make one word card no share"
		post :create do
			@uw = find_or_create_uw(params[:_id])
			file = params[:image].tempfile.path
			type = params[:image].content_type || params[:image].type
			if @uw&&@uw.validate_upload_image(file,type)
				@uw = @uw.make_image(file)
				@uw.geo = [params[:lat],params[:lng]]
				@uw.altitude = params[:altitude].to_f
				@uw.cap_at = Time.parse params[:cap_at]
				@uw.save
				render_json 0,"ok",@uw.image
			else
				render_json -1,"error"
			end
		end

		desc "upload audio"
		post :audio do
			@uw = find_or_create_uw(params[:_id])
			file = params[:file]
			@store_path = UWord::AUDIO_PATH + "#{@uw._id}"
			unless File.exist?(@store_path)
				`mkdir -p #{@store_path}`
			end
			# 压缩成 ogg
			`oggenc -q 4 #{file.tempfile.path} -o #{@uw.audio_path}`
			render_json 0,"ok"
		end
	end

end
