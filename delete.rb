require 'instapaper_full'
myKey = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
mySecret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"
username = 'maxwell.jacobson@gmail.com'
password = 'layabout'

ip = InstapaperFull::API.new :consumer_key => myKey, :consumer_secret => mySecret
ip.authenticate(username, password)
links = ip.bookmarks_list(:limit => 500)

def title_cleanup (title)
  # because it's needless clutter
  title.gsub!(/ - YouTube/, '')
  title.gsub!(/YouTube - /, '')
  title.gsub!(/ on Vimeo/, '')
  title.gsub!(/Watch ([A-Za-z0-9 ]+) \| ([A-Za-z0-9 ]+) online \| Free \| Hulu/, '\1 - \2')
  title.gsub!(/^[ \t\n]+/, '') #some of these have blank shit at the beginning
  title.gsub!(/[ \t\n]+$/, '') #some of these have blank shit at the end
  return title
end

links.each do |l|
  if l["type"] == "bookmark"
    temp_title = title_cleanup(l["title"])
    puts "\nWant to delete this bookmark? (y/N)\n#{temp_title}"
    print "$ "
    maybe = gets.chomp()
    if maybe == "y"
      puts "Deleting #{temp_title}..."
      ip.bookmarks_delete(l)
    end
  end
end

