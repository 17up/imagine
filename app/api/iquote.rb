require 'helpers'

class Iquote < Grape::API
	prefix 'api'
	format :json

	helpers APIHelpers

	before do
		authenticated_device?
	end

	resource :quotes do
		desc "get quotes"
		get "/" do
			num = params[:num] || 50
			tag = params[:tag] || "love"
			data = Eva::Iquote.new(current_device).list(tag,num)
			render_json 0, "ok", data
		end

		desc "get quotes for word"
		get :by_word do
			length = params[:length] || 100
			data = Quote.content_by(params[:title]).lt(length).map(&:as_short_json)
			render_json 0,"ok", data
		end

		desc "like one quote"
		post :like do
			Quote.find(params[:_id]).liked_by(current_device)
			render_json 0, "ok"
		end

	end

end
