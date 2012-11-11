require 'sinatra'
require 'instapaper_full'
require 'oembed'
require 'kramdown'

enable :sessions
set :dump_errors, false
set :show_exceptions, false

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
  if url =~ /embed\//
    # support these two urls:
    # http://m.youtube.com/#/watch?feature=youtu.be&rel=0&v=2NzUm7UEEIY&desktop_uri=%2Fwatch%3Fv%3D2NzUm7UEEIY%26feature%3Dyoutu.be%26rel%3D0
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
  title.gsub!(/^[ \t\n]+/, '') #some of these have blank shit at the beginning
  title.gsub!(/[ \t\n]+$/, '') #some of these have blank shit at the end
  return title
end

not_found do
  @title= "Layabout"
  @subtitle = "404"
  erb :'404'
end

error do
  @title= "Layabout"
  @subtitle = "500"
  erb :'500'
end

get '/faq' do
  @title = "Layabout"
  @subtitle = "FAQ"
  erb :faq
end

get '/' do

  app_key = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  app_secret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"

  @title = "Layabout"
  if session[:username].nil? or session[:password].nil?
    @subtitle = "Log in to Instapaper"
    erb :login
  else
    @subtitle = "Watch"
    ip = InstapaperFull::API.new :consumer_key => app_key, :consumer_secret => app_secret
    ip.authenticate(session[:username], session[:password])
    all_links = ip.bookmarks_list(:limit => 500)
    video_links = Hash.new
    all_links.each do |link|
      if link["type"] == "bookmark"
        info = is_video(link["url"])
        if info[0] == true
          link["vid_site"] = info[1]
          video_links[link["bookmark_id"]] = link
        end
      end
    end
    
    if session[:action] == nil
      puts "session[:action] is nil -- no action this time"
    else
      action_id = session[:action_id].to_i
      the_link = video_links[action_id]
      puts "\n\nsession[:action] is: #{session[:action]}"
      puts "action_id is: #{action_id}"
      puts "the_link is: #{the_link}\n\n"
      if session[:action] == "star"
        if the_link["starred"] == "0"
          ip.bookmarks_star(the_link)
          puts "You liked #{the_link["title"]}"
          video_links[action_id]["starred"] = "1"
        elsif the_link["starred"] == "1"
          ip.bookmarks_unstar(the_link)
          puts "You unliked #{the_link["title"]}"
          video_links[action_id]["starred"] = "0"
        end
      elsif session[:action] == "archive"
        ip.bookmarks_archive(the_link)
        puts "You archived #{the_link["title"]}"
        video_links.delete(action_id)
      elsif session[:action] == "delete"
        ip.bookmarks_delete(the_link)
        puts "You deleted #{the_link["title"]}"
        video_links.delete(action_id)
      elsif session[:action] == "watch"
        video_links[action_id]["to_watch"] = true
        puts "Please enjoy #{the_link["title"]}."
      end
      session[:action] = nil
      session[:action_id] = nil
    end
    
    ## thought: instead of querying instapaper after this kind of thing, just intelligently modify the html array and send it to a fresh :erb???

    html = Array.new
    video_links.each_value do |link|
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
      one_video << "        <h2><a href=\"#{the_url}\" id=\"#{link["bookmark_id"]}\">#{title_cleanup(link["title"])}&rarr;</a></h2>\n"
      
      # if link["to_watch"] == true
        one_video << "        <p>#{resource.html}</p>\n"
      # else
        # one_video << "        <p><a href=\"watch-#{link["bookmark_id"]}\"><img class=\"thumbnail\" width=\"100%\" src=\"#{resource.thumbnail_url}\" /></a></p>\n"
      # end
      
      one_video << "        <p><code>#{the_url}</code></p>\n"

      if link["description"] != ""
        one_video << "        <p>#{make_clicky(link["description"])}</p>\n"
      end
      
      if link["starred"] == "0"
        one_video << "        <p><a href=\"/like-#{link["bookmark_id"]}\"><button class=\"btn btn-primary\">Like <i class=\"icon-heart icon-white\"></i></button></a> "
      elsif link["starred"] == "1"
        one_video << "        <p><a href=\"/like-#{link["bookmark_id"]}\"><button class=\"btn btn-success\">Unlike <i class=\"icon-heart icon-white\"></i></button></a> "
      end
      one_video << "<a href=\"/archive-#{link["bookmark_id"]}\"><button class=\"btn btn-warning\">Archive <i class=\"icon-folder-open icon-white\"></i></button></a> "
      
      if link["starred"] == "0"
        one_video << "<a href=\"/delete-#{link["bookmark_id"]}\"><button class=\"btn btn-danger\">Delete <i class=\"icon-remove icon-white\"></i></button></a></p>\n"
      elsif link["starred"] == "1"
        one_video << "<button class=\"btn btn-inverse\">Delete <i class=\"icon-remove icon-white\"></i></button></p>\n"
      end
      
      
      one_video << "      </div>\n\n"
      html.push(one_video)
    end
    @bookmarks = html.join('')
    erb :vids
  end
end

post '/login' do
  # if params[:u] == '' # TODO obv remove this if statement at some point
  #   session[:username] = "maxwell.jacobson@gmail.com"
  #   session[:password] = "layabout"
  # else
    session[:username] = params[:u]
    session[:password] = params[:pw]
  # end
  redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/:page' do
  if params[:page] =~ /like-[0-9]+/
    session[:action_id] = params[:page].sub(/like-/, '')
    session[:action] = 'star'
    redirect '/' + '#' + session[:action_id]
  elsif params[:page] =~ /archive-[0-9]+/
    session[:action_id] = params[:page].sub(/archive-/, '')
    session[:action] = 'archive'
    redirect '/'
  elsif params[:page] =~ /delete-[0-9]+/
    session[:action_id] = params[:page].sub(/delete-/, '')
    session[:action] = 'delete'
    redirect '/'
  elsif params[:page] =~ /watch-[0-9]+/
    session[:action_id] = params[:page].sub(/watch-/, '')
    session[:action] = 'watch'
    puts "Setting action and action id to watch and your movie!"
    redirect '/' + '#' + session[:action_id]
  elsif File.exists?('views/'+params[:page]+'.erb')
    @title = "Layabout"
    @subtitle = cap_first(params[:page].to_s)
    if params[:page] != 'login'
      erb params[:page].to_sym
    else
      redirect '/'
    end
  else
    @error_page = params[:page]
    raise error(404) 
  end
end