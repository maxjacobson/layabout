class EmbedsController < ApplicationController

  before_action :instantiate_bookmark, only: [:show]

  def show
    @html = (
      film.watchable??
        film.html :
        current_user.instapaper.text(bookmark)
    ).force_encoding('UTF-8')
  end

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