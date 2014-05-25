class EmbedsController < ApplicationController

  before_action :instantiate_bookmark, only: [:show]

  def show
    if current_user
      if film.watchable?
        render json: { watchable: true, html: film.html }
      else
        #render json: { watchable: false, reason: "Sorry, I don't know how to embed that." }
        render json: { watchable: false, readable: true, html: instapaper.text(@bookmark) }
      end
    else
      render json: { watchable: false, reason: "Sorry, this endpoint requires being logged in" }
    end
  rescue Exception => e
    # TODO rescue specific filmsnob error
    render json: { watchable: false, reason: e.to_s }
  end

  private

    def film
      @film ||= FilmSnob.new(params[:url])
    end

    def instapaper
      # FIXME this should be in application controller
      @instapaper ||= current_user.instapaper
    end

    def instantiate_bookmark
      @bookmark = Bookmark.new(bid: params[:bookmark_id])
    end
end
