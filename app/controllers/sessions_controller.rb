class SessionsController < Devise::SessionsController
  def new
  	if params[:admin]
  		set_seo_meta("admin",t('keywords'),t('describe'))
  		super
  	else
  		redirect_to root_path
  	end
  end
end