class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  after_action :verify_authorized, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized
  rescue_from Trailblazer::NotAuthorizedError, with: :trb_user_not_authorized

  private

  def pundit_user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t("#{policy_name}.#{exception.query}", scope: 'pundit', default: :default)
    not_authorized_redirect
  end

  def trb_user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    not_authorized_redirect
  end

  def not_authorized_redirect
    redirect_to(request.referer || root_path)
  end

  def after_sign_in_path_for(resource)
    resource.dispatcher? ? orders_url : route_lists_url
  end
end
