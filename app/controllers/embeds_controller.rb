class EmbedsController < ApplicationController

  def show
    if current_user
      if film.watchable?
        render json: { watchable: true, html: film.html }
      else
        render json: { watchable: false, reason: "Sorry, I don't know how to embed that." }
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
end
