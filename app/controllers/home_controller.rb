class HomeController < ApplicationController

	def index
		set_seo_meta(nil,t('keywords'),t('describe'))
		@num = 1700 - Member.count
	end

	def qq_connect
		set_seo_meta(nil,t('keywords'),t('describe'))
	end

end
