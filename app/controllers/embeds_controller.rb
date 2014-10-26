class EmbedsController < ApplicationController
  before_action :instantiate_bookmark, only: [:show]

  def show
    @html = (
      film.watchable? ? film.html : current_user.instapaper.text(bookmark)
    ).force_encoding('UTF-8')
  end

  private

  def film
    @film ||= FilmSnob.new(params[:url])
  end
  helper_method :film


  def instantiate_bookmark
    @bookmark ||= Bookmark.new(
      bid: params[:bookmark_id],
      liked: (params[:liked] == "true"),
      title: params[:title]
    )
  end

  attr_reader :bookmark
  helper_method :bookmark
end

