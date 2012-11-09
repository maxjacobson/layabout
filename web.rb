require 'sinatra'
require 'instapaper_full'
require 'oembed'

# enable :sessions # what is this? I think important

def is_video (url)
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

def make_clicky (s)
  s.gsub!(/\w*(:\/\/)\w*.[\w#?%=\/]+/, '<a href="\0">\0</a>')
  # TODO make sure this regex is sufficient for recognizing all links
  # the funny thing is, the vast majority of the time (in my experience)
  # that this even comes into play, the link is a link TO the video
  # and is, in fact, the link that I pressed-and-held-on to add the video
  # to instapaper in the first place
  # still
  # I want it to be clickable
  s.gsub!(/@[A-Za-z0-9_]+/, '<a href="http://twitter.com/\0">\0</a>')
  s.gsub!(/twitter.com\/@/, 'twitter.com/')
  return s
end

def youtube_cleanup (url)
  id = url.match(/v=[A-Za-z0-9_-]+/).to_s
  url = 'http://youtube.com/watch?' + id
  return url
end

def youtube_expand (url)
  url.gsub!(/(http:\/\/youtu.be\/)([A-Za-z0-9\-_]+)/, 'http://youtube.com/watch?v=\2')
  return url
end

def title_cleanup (title)
  # because it's needless clutter
  title.gsub!(/ - YouTube/, '')
  title.gsub!(/YouTube - /, '')
  title.gsub!(/ on Vimeo/, '')
  title.gsub!(/Watch ([A-Za-z0-9 ]+) \| ([A-Za-z0-9 ]+) online \| Free \| Hulu/, '\1 - \2')
  # what about paying hulu subscribers... what do their URLs look like?
  title.gsub!(/^[ \t\n]+/, '') #some of these have blank shit at the beginning
  title.gsub!(/[ \t\n]+$/, '') #some of these have blank shit at the end
  # some have blank shit in the middle too but I haven't accounted for those
  return title
end

get '/' do
  
  # I think here I'll need to do something like:
  # if authenticated?
  #   erb :vids
  # else
  #  erb :login
  # end
  
  @title= "Layabout"
  @subtitle = "Login"
  erb :home
end

post '/vids' do
  @title = "Layabout"
  @subtitle = "Watch"
  app_key = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  app_secret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"
  username = params[:u]
  password = params[:pw]
  if username == "" # TODO obviously remove this if statement eventually
    username = "maxwell.jacobson@gmail.com"
    password = "layabout"
  end
  ip = InstapaperFull::API.new :consumer_key => app_key, :consumer_secret => app_secret
  ip.authenticate(username, password)
  all_links = ip.bookmarks_list(:limit => 500)
  video_links = Array.new
  all_links.each do |link|
    if link["type"] == "bookmark"
      info = is_video(link["url"])
      if info[0] == true
        video_links.push(link)
        video_links[-1]["vid_site"] = info[1]
      end
    end
  end
  html = Array.new
  video_links.each do |link|
    one_video = String.new
    the_url = link["url"]
    if link["vid_site"] == "youtube"
      the_url = youtube_cleanup(the_url)
      resource = OEmbed::Providers::Youtube.get(the_url)
    elsif link["vid_site"] == "youtube-short"
      the_url = youtube_expand(the_url)
      resource = OEmbed::Providers::Youtube.get(the_url)
    elsif link["vid_site"] == "vimeo"
      resource = OEmbed::Providers::Vimeo.get(the_url)
    elsif link["vid_site"] == "viddler"
      resource = OEmbed::Providers::Viddler.get(the_url)
    elsif link["vid_site"] == "hulu"
      resource = OEmbed::Providers::Hulu.get(the_url)
    end
    one_video << "<h3><a href=\"#{the_url}\">#{title_cleanup(link["title"])}&rarr;</a></h3>\n"
    one_video << "<a href=\"#{the_url}\"><img class=\"thumbnail\" width=\"100%\" src=\"#{resource.thumbnail_url}\" /></a>\n"
    # one_video << "#{resource.html}\n\n" # this is the embed code for the video.
                                          # I'm not using it right now, the thumbnail is sufficient for me.
                                          # TODO make it so when you click on the thumbnail it replaces the thumbnail with the embed code
    if link["description"] != ""
      one_video << "<p>#{make_clicky(link["description"])}</p>\n"
    end
    one_video << "<p><button class=\"btn btn-primary\">Favorite <i class=\"icon-heart icon-white\"></i></button> "
    one_video << "<button class=\"btn btn-warning\">Archive <i class=\"icon-folder-open icon-white\"></i></button> "
    one_video << "<button class=\"btn btn-danger\">Delete <i class=\"icon-remove icon-white\"></i></button></p>"
    one_video << "\n\n"
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
  <title><%= @title %> - <%= @subtitle %></title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <meta name="HandheldFriendly" content="true" />
  <link rel="stylesheet" href="css/bootstrap.min.css" />
  <link rel="stylesheet" href="css/bootstrap-responsive.min.css" />
</head>
<body>
  <div class="row">
    <div class="span6 offset3">
      <h1><%= @title %></h1>
      <h2><%= @subtitle %></h2>

<%= yield %>

    </div>
    <div class="span3"></div>
  </div>
  <div class="row">
    <div class="span6 offset3">
      <hr />
      <p>A <a href="http://maxjacobson.net">Max Jacobson</a> joint.</p>
    </div>
    <div class="span3"></div>
  </div>
</body>
</html>

@@ home
<p>WATCH YOUR INSTAPAPER</p>
<form action="/vids" method="POST">
  <input type="text" name="u" placeholder="Instapaper Username" autofocus="autofocus">
  <input type="password" name="pw" placeholder="Instapaper Password">
  <button class="btn btn-large btn-block btn-info">Log in</button>
</form>

@@ vids
<%= @bookmarks %>
