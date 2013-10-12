class HomeController < ApplicationController

	def index
		set_seo_meta(nil,t('keywords'),t('describe'))
		@num = 1700 - Member.count
	end

	def mobile
		redirect_to "imagine://org.17up.card"
	end

end
