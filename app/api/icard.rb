require 'helpers'

class Icard < Grape::API
	prefix 'api'
	format :json

	helpers APIHelpers

	before do
		authenticated?
	end

	resource :members do
		desc "get member info by token"
		get "/" do
			data = current_member.as_profile.merge(auth_token: current_member.authentication_token)
			render_json 0,"ok",data
		end
	end

	resource :cards do
		desc "get u_words"
		get "/" do
			data = Eva::Game.new(current_member).list[:data]
			render_json 0, "ok", data
		end

		desc "make one word card"
		post :create do
			@uw = find_or_create_uw(params[:_id])
			file = params[:image].tempfile.path
			type = params[:image].content_type || params[:image].type
			if @uw&&@uw.validate_upload_image(file,type)
				@uw = @uw.make_image(file)
				@uw.desc = params[:desc]
				@uw.save
				# content = I18n.t("word.upload",word: @uw.title)
				# current_member.authorizations.each do |p|
				# 	HardWorker::UploadOlive.perform_async(content,@uw.image_path,p._id.to_s)
				# end
				render_json 0,"ok"
			else
				render_json -1,"error"
			end
		end
	end

end
