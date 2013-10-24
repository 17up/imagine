require 'helpers'
require 'speech'

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
				current_device = DeviceMember.generate("17Word",params.slice(:uuid,:name,:platform))
			end
			render_json 0,"ok",current_device.as_json
		end
	end

	resource :cards do
		# desc "get words"
		# get "/" do
		# 	data = Eva::Icard.new(current_device).list(params[:number] || 1000)
		# 	render_json 0, "ok", data
		# end

		# 联想相关词汇卡片
		desc "imagine u_word by specify word limit 4"
		get :imagine do
			word = Word.find(params[:id])
			limit = params[:limit] || 4
			data = word.u_words.has_image.desc(:u_at).limit(limit).as_json
			render_json 0,"ok", data
		end
		# 加赞
		desc "add good for u_word"
		get :good do
			uw = UWord.find(params[:id])
			uw.good = uw.good + 1
			uw.save
			render_json 0,"ok"
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
			# wav file
			file = params[:file].tempfile.path
			audio = Speech::AudioToText.new(file)
			# resp = audio.to_json
			# resp["hypotheses"][0]
			# singularize / pluralize
			begin
				text = audio.to_text.downcase
				Rails.logger.info text
				if correct = text == @uw.title
					@uw.make_audio(file)
				end
				data = {
					correct: correct,
					text: text
				}
				render_json 0,"ok",data
			rescue => ex
				Rails.logger.info ex.to_s
				render_json -1,"error"
			end
		end
	end

end
