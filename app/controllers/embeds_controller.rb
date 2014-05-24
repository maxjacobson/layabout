class EmbedsController < ApplicationController

  def show
    if film.watchable?
      render json: { watchable: true, html: film.html }
    else
      render json: { watchable: false, reason: "Sorry, I don't know how to embed that." }
    end
  rescue Exception => e
    # TODO rescue specific filmsnob error
    render json: { watchable: false, reason: e }
  end

  private

    def film
      @film ||= FilmSnob.new(params[:url])
    end
end
