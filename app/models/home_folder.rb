# Has similar behaviour to Folder
# But for the home folder
# TODO: Use this in the main app, not just the org rake task
class HomeFolder
  attr_reader :user, :title
  include HasBookmarks

  def initialize(user)
    @user = user
    @title = "Home"
  end

  private

  def bookmarks_options
    {}
  end
end
