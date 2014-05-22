class Instapaper
  def self.for(user)
    new(user.token, user.secret)
  end

  attr_reader :instapaper
  def initialize(token, secret)
    @instapaper = InstapaperFull::API.new(
      consumer_key: Rails.application.secrets.instapaper['consumer_key'],
      consumer_secret: Rails.application.secrets.instapaper['consumer_secret'],
      oauth_token: token,
      oauth_token_secret: secret
    )
  end

  def folders
    instapaper.folders_list.map do |folder|
      Folder.from_api(folder)
    end
  end

  def bookmarks(options)
    instapaper.bookmarks_list(options).map do |bookmark|
      Bookmark.from_api(bookmark)
    end.compact # compact because meta bookmarks are nil
  end


end
