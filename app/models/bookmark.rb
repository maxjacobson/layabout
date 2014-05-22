class Bookmark
  def self.from_api(attributes)
    return nil if attributes['type'].in? ['meta', 'user']
    new(
      description: attributes['description'],
      bid: attributes['bookmark_id'],
      title: attributes['title'],
      url: attributes['url'],
      liked: attributes['starred'] == '1'
    )
  end

  attr_accessor :description, :bid, :title, :url, :liked
  def initialize(attributes)
    @description = attributes[:description] || ''
    @bid = attributes[:bid]
    @title = attributes[:title]
    @url = attributes[:url]
    @liked = attributes[:liked]
  end
end
