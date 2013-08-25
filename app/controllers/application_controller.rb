class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def set_seo_meta(title,keywords = '',desc = '')
    if title
      @title = "#{title}"
      @title += "&raquo;"+t('title')
    else
      @title = t('title')
    end
    @meta_keywords = keywords
    @meta_description = desc
  end

  def render_json(status,msg,data = {})
    render json: { status: status, msg: msg, data: data }
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: lambda { |exception| render_error 500, exception }
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, Mongoid::Errors::DocumentNotFound, with: lambda { |exception| render_error 404, exception }
  end

  private
  def render_error(status, exception)
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", layout: 'layouts/errors', status: status }
      format.all { render nothing: true, status: status }
    end
	end
end
