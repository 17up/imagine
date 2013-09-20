require 'helpers'

class Icard < Grape::API
	prefix 'api'
	format :json

	helpers APIHelpers

	before do
		authenticated?
	end

	resource :cards do
		desc "get u_words"
		get "/" do
			data = Eva::Game.new(current_member).list[:data]
			render_json 0, "ok", data
		end

		desc "make one word card"
		params do
			requires :_id, type: Integer, desc: "Word ID"
		end
		post :create do
			@uw = find_or_create_uw(params[:_id])
			file = params[:image].tempfile.path
			type = params[:image].content_type
			if @uw&&@uw.validate_upload_image(file,type)
				@uw = @uw.make_image(file)
				@uw.img_info = params[:info]
				@uw.save
				# content = I18n.t("word.upload",word: @uw.title)
				# current_member.authorizations.each do |p|
				# 	HardWorker::UploadOlive.perform_async(content,@uw.image_path,p._id.to_s)
				# end
				img = @uw.image_url + "?#{Time.now.to_i}"
				render_json 0,t("flash.success.upload.uword"),img
			else
				render_json -1,"error"
			end
		end
	end

end
