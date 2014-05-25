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

  def like(bookmark)
    instapaper.bookmarks_star bookmark_id: bookmark.bid
  end

  def unlike(bookmark)
    instapaper.bookmarks_unstar bookmark_id: bookmark.bid
  end

  def archive(bookmark)
    instapaper.bookmarks_archive bookmark_id: bookmark.bid
  end

  def move(bookmark, options)
    instapaper.bookmarks_move bookmark_id: bookmark.bid, folder_id: options[:to].fid
  end

  def text(bookmark)
    instapaper.bookmarks_get_text bookmark_id: bookmark.bid
  end

end
