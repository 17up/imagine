Veggie::Application.routes.draw do

	mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
	mount API => '/'

	require 'sidekiq/web'
	constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
	constraints constraint do
		mount Sidekiq::Web => '/sidekiq'
	end

	devise_for :members, :controllers => {
		:omniauth_callbacks => :authentications,
		:sessions => :sessions
	}

	get "/mobile/index"
	# olive
	get "o", :to => "olive#index", :as => :olive
	resources :olive do
		collection do
			get :courses,:quotes,:songs
			post :create_quote,:destroy_tag
		end
	end

	namespace :courses do
		post 'checkin'
		post 'update'
		post 'ready'
		post 'open'
		post 'destroy'
	end

	get "w/:id", :to => "words#show"
	get "uw/:id", :to => "words#u_show"
	namespace :words do
		get "index"
		post 'fetch'
		post "add_imagine"
	end

	namespace :songs do
		post 'create'
		post 'upload'
	end

	# members
	get "account",:to => "members#index"
	get "achieve",:to => "members#index"
	get "teach",:to => "members#index"
	namespace :members do
		post "update"
		post "upload_avatar"
		post "upload_audio"
		post "send_invite"
		get "dashboard"
		get "account"
		get "profile"
		get "provider"
		get "teach"
		get "friend"
		get "timeline"
		post "like"
		post "invite_friend"
	end

	resources :invites

	# 如果是移动设备，则以移动版本渲染
	# mobile_devise = lambda { |request|
	# 	agent = request.user_agent.downcase
	# 	agent.include?("iphone") or agent.include?("android")
	# }
	# constraints mobile_devise do
	# 	get "/", :to => 'mobile#index'
	# end

	authenticated :member do
		get "/", :to => "members#index"
	end
	root 'home#index'

	get ":role/:uid",:to => "members#show"

	# See how all your routes lay out with "rake routes"
	unless Rails.application.config.consider_all_requests_local
		get '*not_found', to: 'errors#error_404'
	end
end
