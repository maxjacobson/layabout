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
end
