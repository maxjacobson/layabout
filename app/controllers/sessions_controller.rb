class SessionsController < ApplicationController
  def create
    if (user = UserFinder.for(request)).save
      user.refresh_folders!
      session[:uid] = user.uid
      notice = "Logged in! Welcome, #{user.email || 'video lover'}!"
      redirect_to root_path, notice: notice
    else
      redirect_to root_path, alert: 'Could not not log in, sorry!'
    end
  end

  def destroy
    session.clear
    redirect_to root_path, notice: 'Logged out!'
  end
end

