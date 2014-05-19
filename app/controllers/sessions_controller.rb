class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    user = User.find_or_initialize_by(uid: auth.uid)
    user.active = auth.extra.raw_info.subscription_is_active == '1'
    if user.save
      session[:uid] = user.uid
      redirect_to root_path, notice: "Logged in! Welcome, #{user.uid}"
    else
      redirect_to root_path, alert: 'Could not not log in, sorry!'
    end
  end

  def destroy
    session.clear
    redirect_to root_path, notice: 'Logged out!'
  end
end
