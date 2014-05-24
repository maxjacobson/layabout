class BookmarksController < ApplicationController

  before_action :instantiate_bookmark

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

  private

    def instantiate_bookmark
      @bookmark = Bookmark.new(bid: params[:id])
    end

    def instapaper
      @instapaper ||= current_user.instapaper
    end
end
