class HomeController < ApplicationController

	def index
		set_seo_meta(nil,t('keywords'),t('describe'))
	end

end
