module APIHelpers

	def render_json(status,msg,data = {})
		{ status: status, msg: msg, data: data }
	end

	def current_member
    @current_member ||= Member.authorize!(env)
  end

  def authenticate!
    error!('401 Unauthorized', 401) unless current_member
  end
end
