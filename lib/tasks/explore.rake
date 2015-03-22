require 'readline'
require 'launchy'

class OrgAction
  class << self
    attr_accessor :commands, :command, :description

    def valid_commands
      ([command] + [commands]).flatten.compact
    end
  end

  delegate :command, :commands, :valid_commands, :description, to: :class

  def can_handle?(input)
    valid_commands.any? do |com|
      if com.is_a?(Regexp)
        com =~ input
      else
        com == input
      end
    end
  end

  def act(app)
    handle(app)
    keep_looping?
  end

  # should be overridden if the action should do something
  def handle(app)
    app
  end

  # should we keep looping after this action?
  def keep_looping?
    true
  end

  private

  def with_current_bookmark(app, message)
    if (bookmark = app.current_bookmark).present?
      yield bookmark
    else
      puts message
    end
  end
end

class LikeAction < OrgAction
  self.commands = ['like', 'liked', 'l', '<3']
  self.description = 'Like current bookmark'

  def handle(app)
    with_current_bookmark(app, 'No bookmark...?') do |bookmark|
      app.user.instapaper.like(bookmark)
      puts "😍 Liked #{bookmark.title} 😍"
    end
  end
end

class UnlikeAction < OrgAction
  self.commands = %w(unlike u)
  self.description = 'Unlike current bookmark'

  def handle(app)
    with_current_bookmark(app, 'No bookmark...?') do |bookmark|
      app.user.instapaper.unlike(bookmark)
      puts "Unliked #{bookmark.title}"
    end
  end
end

class ArchiveAction < OrgAction
  self.commands = %w(archive y)
  self.description = 'Archive current bookmark'

  def handle(app)
    with_current_bookmark(app, 'No bookmark...?') do |bookmark|
      app.user.instapaper.archive(bookmark)
      app.remove_current_bookmark
      puts "Archived #{bookmark.title}"
    end
  end
end

class VisitAction < OrgAction
  self.command = 'visit'
  self.description = 'Visit Original url of bookmark'

  def handle(app)
    with_current_bookmark(app, 'Nothing to visit') do |bookmark|
      Launchy.open(bookmark.url)
    end
  end
end

class MoveAction < OrgAction
  self.command = /^mv /
  self.description = 'Move current bookmark to folder (eg. mv 4 or mv offload)'

  def handle(app)
    with_current_bookmark(app, 'No bookmark to move!') do |bookmark|
      if (folder = matched_folder(app.last_command, app.folders)).present?
        app.send_away(bookmark, folder)
        puts "Sent to #{folder.title}: #{bookmark.title}\n"
        ListAction.new.handle(app)
        StatusAction.new.handle(app)
      else
        puts 'Invalid request! (Note: cannot move to home folder rn)'
      end
    end
  end

  private

  def matched_folder(command, folders)
    request = command.gsub('mv ', '')
    match = folders.find do |folder|
      folder.title.downcase.starts_with?(request.downcase)
    end || (folders[request.to_i] if request =~ /^\d+$/)
    match unless match.is_a?(HomeFolder)
  end
end

class ReadAction < OrgAction
  self.commands = %w(read open)
  self.description = 'Read current bookmark'

  def handle(app)
    with_current_bookmark(app, 'No bookmarks in this folder') do |bookmark|
      begin
        open_bookmark(app, bookmark)
      rescue => e
        # sometimes this breaks, but we have a decent fallback
        puts 'Error:'
        p e
        puts 'Opening original URL'
        VisitAction.new.handle(app)
      end
    end
  end

  private

  def open_bookmark(app, bookmark)
    file = Tempfile.new([bookmark.title, '.html'])
    file.write(
      engine.call(
        title: bookmark.title,
        body: HtmlGuarantor.new(app.user, bookmark).html,
        url: bookmark.url
      ).encode(*encoding_options)
    )
    file.rewind
    Launchy.open(file.path)
  end

  def engine
    @engine ||= Haml::Engine.new(
      template
    ).render_proc(
      render_context,
      :title,
      :body,
      :url
    )
  end

  def template
    @template ||= File.read(template_path)
  end

  def template_path
    Rails.root.join('app', 'views', 'layouts', 'minimalist.html.haml')
  end

  def render_context
    Object.new
  end

  def encoding_options
    [
      'utf-8',
      {
        invalid: :replace,
        undef: :replace,
        replace: '_'
      }
    ]
  end
end

class ListAction < OrgAction
  self.commands = %w(list ls)
  self.description = 'List the folders'

  def handle(app)
    app.folders.each.with_index do |folder, index|
      puts "#{index} - #{folder.title}"
    end
  end
end

class SwitchFolderAction < OrgAction
  self.commands = [/^cd \d+$/, /^\d+$/]
  self.description = 'Change to folder at provided index (eg. cd 4)'

  def handle(app)
    folder_index = app.last_command.gsub('cd ', '').to_i
    if (folder = app.folders[folder_index]).present?
      app.current_folder = folder
      puts "Switched to #{app.current_folder.title}"
      with_current_bookmark(app, 'This folder is empty') do |bookmark|
        puts bookmark.title
      end
    else
      puts 'Invalid folder index!'
    end
  end
end

class StatusAction < OrgAction
  self.description = 'Print the current folder'
  self.commands = %w(status st)

  def handle(app)
    puts "Current folder: #{app.current_folder.title} (#{app.bookmarks.count})"
    puts

    with_current_bookmark(app, 'No active bookmark') do |bookmark|
      puts bookmark.title
      puts bookmark.url
    end
  end
end

class ExitAction < OrgAction
  self.description = 'Quit the org app'
  self.commands = %w(exit quit break q)

  def keep_looping?
    false
  end
end

class HelpAction < OrgAction
  self.description = 'Print all the valid actions'
  self.command = 'help'

  def handle(_)
    puts 'Valid commands:'
    OrgAction.subclasses.each do |action|
      next if action == NoMatchAction # Should not be invoked directly!
      puts "[#{action.valid_commands.join(',')}] => #{action.description}"
    end
  end
end

class EmptyInput < OrgAction
  self.description = 'No input! Just relax'
  self.command = ''
end

# Must be last-defined action, it catches all the non-matches
class NoMatchAction < OrgAction
  def can_handle?(_)
    true
  end

  def handle(_)
    puts "No match! Try typing 'help'"
  end
end

class OrgApp
  attr_reader :user, :current_folder, :last_command, :folders

  def initialize(user)
    @user = user
    validate_user
    @folders = [HomeFolder.new(user)] + user.folders.to_a
    @current_folder = @folders.first
    @bookmark_index = 0
  end

  def handle(command)
    @last_command = command
    actions.find { |action| action.can_handle?(command) }.act(self)
  end

  def current_bookmark
    bookmarks[bookmark_index]
  end

  def current_folder=(folder)
    @bookmarks = nil    # releasing this memory!
    @bookmark_index = 0 # back to the top!
    @current_folder = folder
  end

  def send_away(bookmark, folder)
    user.instapaper.move(bookmark, to: folder)
    remove_current_bookmark
  end

  def bookmarks
    @bookmarks ||= current_folder.bookmarks
  end

  def remove_current_bookmark
    @bookmarks.delete_at(bookmark_index)
  end

  def next_command
    Readline.readline('> ', true)
  rescue Interrupt
    'exit'
  end

  private

  attr_reader :bookmark_index

  def actions
    @actions ||= OrgAction.subclasses.map(&:new)
  end

  def validate_user
    raise 'No users in db! Sign in thru browser first' unless user.present?
    raise 'Sorry, must be a paying Instapaper subscribe' unless user.active?
  end
end

task explore: :environment do
  app = OrgApp.new(User.first)
  ':)' while app.handle(app.next_command)
end

