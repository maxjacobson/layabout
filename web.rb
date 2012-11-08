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
  puts "Before: #{url}"
  id = url.match(/v=[A-Za-z0-9_-]+/).to_s
  url = 'http://youtube.com/watch?' + id
  puts "After: #{url}"
  return url
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
  links = ip.bookmarks_list(:limit => 50)
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
    elsif a[1] == "vimeo"
      resource = OEmbed::Providers::Vimeo.get(a[0]["url"])
    elsif a[1] == "viddler"
      resource = OEmbed::Providers::Viddler.get(a[0]["url"])
    elsif a[1] == "hulu"
      resource = OEmbed::Providers::Hulu.get(a[0]["url"])
    end
    one_video << "<h2>#{a[0]["title"]}</h2>\n"
    one_video << "<a href=\"#{temp_url}\"><img class=\"thumbnail\" width=\"500px\" src=\"#{resource.thumbnail_url}\" /></a>"
    #one_video << "#{resource.html}\n\n"
    if a[0]["description"] != ""
      one_video << "<p>#{clickableLinks(a[0]["description"])}</p>\n"
    end

    one_video << "<p><button class=\"btn btn-primary\">Favorite <i class=\"icon-heart icon-white\"></i></button> <button class=\"btn btn-warning\">Archive <i class=\"icon-book icon-white\"></i></button> <button class=\"btn btn-danger\">Delete <i class=\"icon-remove icon-white\"></i></button></p>"

    one_video << "<hr />"
    html.push(one_video)
  end
  num_videos_to_display = 500 # if you want to limit the output to like the 3 most recent or something
  if num_videos_to_display >= html.length
    num_videos_to_display = html.length - 1
  end
  # for i in 0..num_videos_to_display
  #   puts html[i]
  # end
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
    <div class="span8 offset2">
      <h1><%= @title %></h1>
      <%= yield %>
    </div>
    <div class="span 2"></div>
  </div>
</body>
</html>

@@ home
<p>Layabout is a fun way to watch the videos in your Intapaper queue.</p>
<p>This only works for subscribers, sorry. Should I add support for things like Pinboard or Pocket?</p>
<form action="/vids" method="POST">
  <input type="text" name="u" placeholder="Instapaper Username" autofocus="autofocus">
  <input type="password" name="pw" placeholder="Instapaper password">
  <button class="btn btn-large btn-block btn-info">Log in</button>
</form>

@@ vids
<%= @bookmarks %>
