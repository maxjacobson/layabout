# Provides a #bookmarks method
# Provides a #videos method, which filters the bookmarks
#
# Expectations:
#
# included in an object with a #user method
# included in an object with a bookmarks_options method
module HasBookmarks
  extend ActiveSupport::Concern

  def bookmarks
    @bookmarks ||= instapaper.bookmarks({ limit: 500 }.merge(bookmarks_options))
  end

  def videos
    bookmarks.keep_if(&:embeddable?)
  end

  private

  def instapaper
    @instapaper ||= Instapaper.for(user)
  end
end

