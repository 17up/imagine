require 'helpers'

class Iquote < Grape::API
	prefix 'api'
	format :json

	helpers APIHelpers

	resource :quotes do
		desc "get quotes"
		get :index do
			render_json 0, "ok", Eva::Quote.new(nil).collection
		end

		desc "like one quote"
		params do
			requires :_id, type: Integer, desc: "quote ID"
			requires :auth_token, type: String, desc: "authentication_token"
		end
		post :like do
			Quote.find(params[:_id]).liked_by(current_member)
			render_json 0, "ok"
		end
	end

end
