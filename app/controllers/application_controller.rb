class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # TODO use a user model instead of this nonsense
  # also some kind of encrypted key I guess
  def current_user
    if session[:uid]
      @current_user ||= User.find_by(uid: session[:uid])
    end
  end
  helper_method :current_user

end
