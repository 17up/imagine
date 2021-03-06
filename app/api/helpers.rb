module APIHelpers

	def render_json(status,msg,data = {})
		{ status: status, msg: msg, data: data }
	end

	def warden
		env['warden']
	end

	def auth_token
		params[:auth_token]
	end

	def authenticated?
		if warden.authenticated?
			return true
		elsif auth_token and Member.authorize(auth_token)
	            return true
		else
			error!({"error" => "Unauth 401"}, 401)
		end
	end

	def current_member
		warden.user ||  Member.authorize(auth_token)
	end

	# device_member
	def authenticated_device?
		if params[:uuid].present?
			return true
		else
			error!({"error" => "Unauth 401"}, 401)
		end
	end

	def current_device
		DeviceMember.auth_device(params[:uuid])
	end

	def find_or_create_uw(id)
		@word = Word.find(id)
		unless @uw = current_device.has_u_word(@word)
			@uw = current_device.u_words.new(word_id: @word._id)
		end
		@uw
	end
end

