class Bookmark
  def self.from_api(attributes)
    return nil if attributes['type'].in? %w(meta user)
    new(
      description: attributes['description'],
      bid: attributes['bookmark_id'],
      title: attributes['title'],
      url: attributes['url'],
      liked: attributes['starred'] == '1'
    )
  end

  attr_accessor :description, :bid, :url, :liked
  alias_method :liked?, :liked
  delegate :watchable?, to: :film

  def initialize(attributes)
    @description = attributes[:description] || ''
    @bid = attributes[:bid]
    @title = attributes[:title]
    @url = attributes[:url]
    @liked = attributes[:liked]
  end

  def title
    @title.presence || film.title
  rescue
    'Title unavailable'
  end

  def html
    film.html
  rescue FilmSnob::NotEmbeddableError
    'Sorry, not embeddable'
  end

  def film
    @film ||= FilmSnob.new(url, width: 100)
  end
end

