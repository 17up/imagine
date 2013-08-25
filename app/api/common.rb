class Common < Grape::API
	prefix 'api'
	format :json
	helpers APIHelpers

	desc "new member"
	def register
		member = Member.new
		member.ensure_authentication_token!
	end

end
