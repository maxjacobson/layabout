module BookmarksHelper
  def video_class_for(bookmark)
    "#{bookmark.bid} #{'liked' if bookmark.liked?}"
  end
end

