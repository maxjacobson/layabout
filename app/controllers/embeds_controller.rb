class EmbedsController < ApplicationController

  before_action :instantiate_bookmark, only: [:show]

  private

    def film
      @film ||= FilmSnob.new(params[:url])
    end
    helper_method :film

    def instapaper
      # FIXME this should be in application controller
      @instapaper ||= current_user.instapaper
    end

    def instantiate_bookmark
      @bookmark ||= Bookmark.new(bid: params[:bookmark_id])
    end

    def bookmark
      @bookmark
    end
    helper_method :bookmark
end
