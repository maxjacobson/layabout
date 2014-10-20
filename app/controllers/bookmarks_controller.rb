class BookmarksController < ApplicationController
  before_action :instantiate_bookmark
  before_action :instantiate_folder, only: [:move]

  def archive
    instapaper.archive @bookmark
  end

  def like
    @bookmark.liked = true
    instapaper.like @bookmark
  end

  def unlike
    @bookmark.liked = false
    instapaper.unlike @bookmark
  end

  def move
    instapaper.move @bookmark, to: @folder
  end

  private

  def instantiate_bookmark
    @bookmark = Bookmark.new(bid: params[:id])
  end

  Folder = Struct.new(:fid)
  def instantiate_folder
    @folder = Folder.new(params[:folder_id])
  end

  def instapaper
    @instapaper ||= current_user.instapaper
  end
end

