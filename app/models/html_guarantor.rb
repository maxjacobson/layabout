class HtmlGuarantor
  def initialize(user, bookmark)
    @user = user
    @bookmark = bookmark
  end

  def html
    film.embeddable? ? film.html : text
  rescue FilmSnob::NotEmbeddableError
    text
  end

  private

  attr_reader :user, :bookmark

  def film
    @film ||= FilmSnob.new(bookmark.url)
  end

  def text
    user.instapaper.text(bookmark)
  end
end
