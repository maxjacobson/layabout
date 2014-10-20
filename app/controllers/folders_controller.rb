class FoldersController < ApplicationController
  def show
    @folder = current_user.folders.find_by(slug: params[:slug])
  end
end

