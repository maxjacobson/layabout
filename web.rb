require 'sinatra'
require 'instapaper_full'
require 'oembed'

def isVideo (url)
  if url =~ /youtube.com/
    return [true, "youtube"]
  elsif url =~ /vimeo.com/
    return [true, "vimeo"]
  elsif url =~ /viddler.com/
    return [true, "viddler"]
  elsif url =~ /hulu.com/
    return [true, "hulu"]
  elsif url =~ /youtu.be/
    return [true, "youtube-short"]
  else
    return [false]
  end
end

def clickableLinks (s)
  # TODO make sure this regex is sufficient
  link_regex = /\w*(:\/\/)\w*.[\w#?%=\/]+/
  s.gsub!(link_regex, '<a href="\0">\0</a>')
  return s
end

def youtube_cleanup (url)
  id = url.match(/v=[A-Za-z0-9_-]+/).to_s
  url = 'http://youtube.com/watch?' + id
  return url
end

def youtube_expand (url)
  url.gsub!(/(http:\/\/youtu.be\/)([A-Za-z0-9\-_]+)/, 'http://youtube.com/watch?v=\2')
end

def title_cleanup (title)
  title.gsub!(/ - YouTube/, '')
  title.gsub!(/Youtube - /, '')
  title.gsub!(/ on Vimeo/, '')
  title.gsub!(/Watch ([A-Za-z0-9 ]+) \| ([A-Za-z0-9 ]+) online \| Free \| Hulu/, '\1 - \2')
  return title
end


get '/' do
  @title= "Layabout - Login"
  erb :home
end

post '/vids' do
  @title = "Layabout - Watch"
  myKey = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  mySecret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"
  username = params[:u]
  password = params[:pw]

  ip = InstapaperFull::API.new :consumer_key => myKey, :consumer_secret => mySecret
  ip.authenticate(username, password)
  links = ip.bookmarks_list(:limit => 500)
  videoLinks = Array.new
  i = 2 # because the first two hashes in the bookmarks_list array are not bookmarks
  # TODO rewrite like in the sample code on https://github.com/vanderwal/instapaper_full `if b['type'] == 'bookmark'`
  while i < links.length
    info = isVideo(links[i]["url"])  
    if info[0] == true
      videoLinks.push([links[i], info[1]])
    end
    i += 1
  end
  # doing this goofy array thing so I can later selectively share some but not all of the videos
  html = Array.new
  videoLinks.each do |a|
    one_video = String.new
    if a[1] == "youtube"
      temp_url = youtube_cleanup(a[0]["url"])
      resource = OEmbed::Providers::Youtube.get(temp_url)
    elsif a[1] == "youtube-short"
      temp_url = youtube_expand(a[0]["url"])
      resource = OEmbed::Providers::Youtube.get(temp_url)
    elsif a[1] == "vimeo"
      resource = OEmbed::Providers::Vimeo.get(a[0]["url"])
    elsif a[1] == "viddler"
      resource = OEmbed::Providers::Viddler.get(a[0]["url"])
    elsif a[1] == "hulu"
      resource = OEmbed::Providers::Hulu.get(a[0]["url"])
    end
    one_video << "<h2><a href=\"#{temp_url}\">#{title_cleanup(a[0]["title"])}</a></h2>\n"
    one_video << "<a href=\"#{temp_url}\"><img class=\"thumbnail\" width=\"100%\" src=\"#{resource.thumbnail_url}\" /></a>"
    #one_video << "#{resource.html}\n\n"
    if a[0]["description"] != ""
      one_video << "<p>#{clickableLinks(a[0]["description"])}</p>\n"
    end
    one_video << "<p><button class=\"btn btn-primary\">Favorite <i class=\"icon-heart icon-white\"></i></button> "
    one_video << "<button class=\"btn btn-warning\">Archive <i class=\"icon-book icon-white\"></i></button> "
    one_video << "<button class=\"btn btn-danger\">Delete <i class=\"icon-remove icon-white\"></i></button></p>"
    html.push(one_video)
  end
  @bookmarks = html.join('')
  erb :vids
end

__END__

@@ layout
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title><%= @title %></title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <meta name="HandheldFriendly" content="true" />
  <link rel="stylesheet" href="css/bootstrap.css" />
  <link rel="stylesheet" href="css/bootstrap-responsive.css" />
</head>
<body>
  <div class="row">
    <div class="span6 offset3">
      <h1><%= @title %></h1>
      <%= yield %>
    </div>
    <div class="span 3"></div>
  </div>
</body>
</html>

@@ home
<p>Layabout is a fun way to watch the videos in your Instapaper queue.</p>
<p>This only works for subscribers, sorry. Should I add support for things like Pinboard or Pocket?</p>
<form action="/vids" method="POST">
  <input type="text" name="u" placeholder="Instapaper Username" autofocus="autofocus">
  <input type="password" name="pw" placeholder="Instapaper password">
  <button class="btn btn-large btn-block btn-info">Log in</button>
</form>

@@ vids
<%= @bookmarks %>
