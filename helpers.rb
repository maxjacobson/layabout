def get_footer
  return "<div class=\"row\"><div class=\"span8 offset3\"><hr /><p>A <a href=\"http://maxjacobson.net\">Max Jacobson</a> joint. <a href=\"/faq\">FAQ</a>.</p></div><div class=\"span1\"></div></div>"
end
def get_header

  return "<div class=\"navbar\">\n<div class=\"navbar-inner\">\n<a class=\"brand\" href=\"/\">Layabout</a></div></div>\n" if @display_header == false
  app_key = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  app_secret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"
  ip = InstapaperFull::API.new :consumer_key => app_key, :consumer_secret => app_secret
  ip.authenticate(session[:username], session[:password])
  folders_list = ip.folders_list
  header = Array.new
  header.push("<div class=\"navbar\">\n<div class=\"navbar-inner\">\n<a class=\"brand\" href=\"/\">Layabout</a>\n")
  header.push("<div class=\"pull-right\"><form action=\"/search\" id=\"searchbox\" class=\"navbar-search\"><input type=\"text\" class=\"search-query\" placeholder=\"Search...\" name=\"q\"></form>\n")
  header.push("<ul class=\"nav\">\n")

  if folders_list.length > 0
    folder_nav = String.new
    folder_nav << "<li class=\"dropdown\">\n"
    folder_nav << "<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\">Switch folder <b class=\"caret\"></b></a>\n<ul class=\"dropdown-menu\">"
    folder_nav << "<li><a href=\"/switch-to-folder/main\">Read Later</a></li>\n<li class=\"divider\"></li>\n"
    folders_list.each do |folder|
      folder_nav << "<li><a href=\"/switch-to-folder/#{folder["folder_id"]}\">#{folder["title"]}</a></li>\n"
    end
    folder_nav << "</ul>\n</li>\n"
    header.push(folder_nav)
  end
  header.push("<li><a href=\"/faq\">FAQs</a></li>")
  header.push("<li><a href=\"/logout\">Log out</a></li>\n</ul>\n</div></div></div>")

  return header.join('')
end

def cap_first (s)
  # this code via stack overflow http://stackoverflow.com/questions/2646709/capitalize-only-first-character-of-string-and-leave-others-alone-rails
  return s.slice(0,1).capitalize + s.slice(1..-1)
end

def is_video (url)
  if url =~ /youtube.com/
    return [true, "youtube"]
  elsif url=~ /vimeo.com\/m\//
    return [true, "vimeo-mobile"]
  elsif url =~ /vimeo.com/
    return [true, "vimeo"]
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
  s.gsub!(/@[A-Za-z0-9_]+/, '<a href="http://twitter.com/\0">\0</a>')
  s.gsub!(/twitter.com\/@/, 'twitter.com/')
  return s
end

def youtube_cleanup (url)
  if url =~ /embed\//
    id = url.match(/\/embed\/[A-Za-z0-9_-]+/).to_s
    id.gsub!(/\/embed\//,'v=')
  else
    id = url.match(/v=[A-Za-z0-9_-]+/).to_s
  end
  url = 'http://youtube.com/watch?' + id
  return url
end

def vimeo_cleanup (url)
  url.gsub!(/vimeo.com\/m\//,'vimeo.com/')
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
  title.gsub!(/Watch ([A-Za-z0-9 ]+) \| ([A-Za-z0-9 ]+) online \| Free \| Hulu/, '\1: \2')
  title.gsub!(/^[ \t\n]+/, '')
  title.gsub!(/[ \t\n]+$/, '')
  return title
end

def video_to_html (link)
  one_video = String.new
  the_url = link["url"]
  if link["vid_site"] == "youtube"
    the_url = youtube_cleanup(the_url)
    resource = OEmbed::Providers::Youtube.get(the_url)
  elsif link["vid_site"] == "youtube-short"
    the_url = youtube_expand(the_url)
    resource = OEmbed::Providers::Youtube.get(the_url)
  elsif link["vid_site"] == "vimeo"
    resource = OEmbed::Providers::Vimeo.get(the_url, maxwidth: "500", portrait: false, byline: false, title: false)
  elsif link["vid_site"] == "vimeo-mobile"
    the_url = vimeo_cleanup(the_url)
    resource = OEmbed::Providers::Vimeo.get(the_url, maxwidth: "500", portrait: false, byline: false, title: false)
  elsif link["vid_site"] == "hulu"
    resource = OEmbed::Providers::Hulu.get(the_url)
  end
  one_video << "      <hr />\n"
  one_video << "      <div class=\"video-container\" id=\"#{link["bookmark_id"]}\">\n"
  one_video << "        <h2><a href=\"#{the_url}\" id=\"#{link["bookmark_id"]}\">#{title_cleanup(resource.title)}&rarr;</a></h2>\n"
  one_video << "        <p>#{resource.html}</p>\n"
  one_video << "        <p><code><a href=\"#{the_url}\">#{the_url}</a></code></p>\n"

  if link["description"] != ""
    one_video << "        <p>#{make_clicky(link["description"])}</p>\n"
  end

  if link["starred"] == "0"
    one_video << "        <p><a href=\"/like/#{link["bookmark_id"]}\"><button class=\"btn btn-primary\">Like <i class=\"icon-heart icon-white\"></i></button></a> "
    one_video << "<a href=\"/like-and-archive/#{link["bookmark_id"]}\"><button class=\"btn btn-primary\">Like and Archive <i class=\"icon-heart icon-white\"></i> <i class=\"icon-folder-open icon-white\"></i></button></a> "
  elsif link["starred"] == "1"
    one_video << "        <p><a href=\"/unlike/#{link["bookmark_id"]}\"><button class=\"btn btn-success\">Unlike <i class=\"icon-heart icon-white\"></i></button></a> "
  end
  one_video << "<a href=\"/archive/#{link["bookmark_id"]}\"><button class=\"btn btn-warning\">Archive <i class=\"icon-folder-open icon-white\"></i></button></a> "

  if link["starred"] == "0"
    one_video << "<a href=\"/delete/#{link["bookmark_id"]}\"><button class=\"btn btn-danger\">Delete <i class=\"icon-remove icon-white\"></i></button></a></p>\n"
  elsif link["starred"] == "1"
    one_video << "<button class=\"btn btn-danger disabled\">Delete <i class=\"icon-remove icon-white\"></i></button> "
    one_video << "<a href=\"/unlike-and-delete/#{link["bookmark_id"]}\"><button class=\"btn btn-danger\">Unlike and Delete <i class=\"icon-remove icon-white\"></i></button></a></p>\n"
  end
  one_video << "      </div>\n\n"
  return one_video
end

def perform_action(instructions)
  app_key = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  app_secret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"
  ip = InstapaperFull::API.new :consumer_key => app_key, :consumer_secret => app_secret
  ip.authenticate(session[:username], session[:password])
  action = instructions[:action]
  link = {"bookmark_id" => instructions[:id]}
  if action == :like
    ip.bookmarks_star(link)
  elsif action == :unlike
    ip.bookmarks_unstar(link)
  elsif action == :archive
    ip.bookmarks_archive(link)
  elsif action == :delete
    ip.bookmarks_delete(link)
  elsif action == :like_and_archive
    ip.bookmarks_star(link)
    ip.bookmarks_archive(link)
  elsif action == :unlike_and_delete
    ip.bookmarks_unstar(link)
    ip.bookmarks_delete(link)
  end
end