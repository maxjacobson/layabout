class EmbedsController < ApplicationController
  before_action :instantiate_bookmark, only: [:show]

  def show
    @html = html.force_encoding('UTF-8')
  end

  private

  def film
    @film ||= FilmSnob.new(params[:url])
  end
  helper_method :film

  def instapaper
    # FIXME: this should be in application controller
    @instapaper ||= current_user.instapaper
  end

  def instantiate_bookmark
    @bookmark ||= Bookmark.new(bid: params[:bookmark_id])
  end

  attr_reader :bookmark
  helper_method :bookmark

  def html
    film.embeddable? ? film.html : text
  rescue FilmSnob::NotEmbeddableError
    text
  end

  def text
    current_user.instapaper.text(bookmark)
  end
end

