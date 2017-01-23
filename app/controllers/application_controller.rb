class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  force_ssl if: :ssl_configured?
  before_action :hide_topbar

  def ssl_configured?
    !Rails.env.development?
  end

  def show_topbar
    @show_topbar = true
  end

  def hide_topbar
    @show_topbar = false
  end
end
