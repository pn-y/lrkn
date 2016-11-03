module ApplicationHelper
  def current_user_dispatcher?
    user_signed_in? && current_user.dispatcher?
  end
end
