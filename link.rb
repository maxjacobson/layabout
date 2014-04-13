class Link
  attr_reader :id, :instapaper

  def initialize(id, instapaper)
    @id = id.to_i
    @instapaper = instapaper
  end

  def like!
    instapaper.bookmarks_star "bookmark_id" => id
  end

  def unlike!
    instapaper.bookmarks_unstar "bookmark_id" => id
  end

  def archive!
    instapaper.bookmarks_archive "bookmark_id" => id
  end

  def unarchive!
    instapaper.bookmarks_unarchive "bookmark_id" => id
  end

  def delete!
    instapaper.bookmarks_delete "bookmark_id" => id
  end

  def like_and_archive!
    instapaper.bookmarks_star "bookmark_id" => id
    instapaper.bookmarks_archive "bookmark_id" => id
  end

  def unliked_and_delete!
    instapaper.bookmarks_unstar "bookmark_id" => id
    instapaper.bookmarks_delete "bookmark_id" => id
  end

  def move_to!(folder_id)
    instapaper.bookmarks_move "bookmark_id" => id, "folder_id" => folder_id.to_i
  end

end
