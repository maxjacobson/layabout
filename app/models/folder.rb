class Folder < ActiveRecord::Base
  belongs_to :user

  def self.from_api(attributes)
    new(
      title: attributes['title'],
      fid: attributes['folder_id'],
      slug: attributes['slug']
    )
  end

  # FIXME surely there is a better way to do this :)
  def path
    '/folders/' + slug
  end

  def bookmarks
    @bookmarks ||= instapaper.bookmarks(folder_id: fid, limit: 500)
  end

  def videos
    bookmarks.keep_if do |bookmark|
      bookmark.watchable?
    end
  end

  private

    def instapaper
      @instapaper ||= Instapaper.for(user)
    end

end
