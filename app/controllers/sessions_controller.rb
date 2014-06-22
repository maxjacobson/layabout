class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    user = User.find_or_initialize_by(uid: auth.uid.to_s)
    user.active = auth.extra.raw_info.subscription_is_active == '1'
    user.email = auth.extra.raw_info.username
    user.token, user.secret = auth.credentials.values
    user.last_synced_at = Time.now
    if user.save
      user.refresh_folders!
      session[:uid] = user.uid
      redirect_to root_path, notice: "Logged in! Welcome, #{user.email || 'video lover'}!"
    else
      redirect_to root_path, alert: 'Could not not log in, sorry!'
    end
  end

  def destroy
    session.clear
    redirect_to root_path, notice: 'Logged out!'
  end
end
