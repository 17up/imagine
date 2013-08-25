# coding: utf-8
class AuthenticationsController < Devise::OmniauthCallbacksController

  Authorization::PROVIDERS.each do |m|
    define_method m do
      omniauth_process
    end
  end
  
  def passthru
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false
  end
  
  protected
    def omniauth_process
      omniauth = request.env['omniauth.auth']
      provider = Authorization.where(provider: omniauth.provider, uid: omniauth.uid.to_s).first
      expires_time = omniauth.credentials.expires_at.blank? ? nil : Time.at(omniauth.credentials.expires_at.to_i)
      # 已登录状态下，绑定流程
      if current_member
				# 非正常情况：用户发起绑定一个第三方帐号，但是该provider已存在，并且持有人不是当前member
        if provider
          if provider.member == current_member
            reset_token_secret(provider,omniauth,expires_time) 
          else
					  flash[:error] = t('flash.error.bind',email: $config[:email])
          end
				# 正常绑定
        else
          current_member.bind_service(omniauth, expires_time)
          flash[:success] = t('flash.notice.bind')         
        end
        redirect_to "/account#/ahome"
			# 非登录状态下，注册/登录
      else
				# 登录
        if provider
          reset_token_secret(provider, omniauth, expires_time) 
          sign_in(provider.member)
				# 注册
        else
          new_user = Member.generate
          new_user.bind_service(omniauth, expires_time)
          sign_in(new_user)
          if session[:invite]
            new_user.invited_by(Invite.find(session[:invite]))
            session[:invite] = nil
          end
          flash[:success] = t('flash.notice.welcome',name: new_user.name)      
        end
        redirect_to "/"
      end
    end

    def after_omniauth_failure_path_for(scope)
      root_path
    end
    
    def reset_token_secret(provider,omniauth,expires_time)    
        provider.update_attributes(token: omniauth.credentials.token,
                                   secret: omniauth.credentials.secret,
                                   info: omniauth.info,
                                   expired_at: expires_time,
                                   refresh_token: omniauth.credentials.refresh_token)
    end
end
