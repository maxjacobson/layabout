require 'sinatra'
require 'instapaper_full'
require 'oembed'
require 'kramdown'

enable :sessions

def cap_first (s)
  # this code via stack overflow http://stackoverflow.com/questions/2646709/capitalize-only-first-character-of-string-and-leave-others-alone-rails
  return s.slice(0,1).capitalize + s.slice(1..-1)
end

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
      one_video << "      <h3><a href=\"#{the_url}\">#{title_cleanup(link["title"])}&rarr;</a></h3>\n"
      one_video << "      <a href=\"#{the_url}\"><img class=\"thumbnail\" width=\"100%\" src=\"#{resource.thumbnail_url}\" /></a>\n"
      # one_video << "#{resource.html}\n\n" # this is the embed code for the video.
                                            # I'm not using it right now, the thumbnail is sufficient for me.
                                            # TODO make it so when you click on the thumbnail it replaces the thumbnail with the embed code
      if link["description"] != ""
        one_video << "      <p>#{make_clicky(link["description"])}</p>\n"
      end
      one_video << "      <p><button class=\"btn btn-primary\">Like <i class=\"icon-heart icon-white\"></i></button> "
      one_video << "<button class=\"btn btn-warning\">Archive <i class=\"icon-folder-open icon-white\"></i></button> "
      one_video << "<button class=\"btn btn-danger\">Delete <i class=\"icon-remove icon-white\"></i></button></p>"
      one_video << "\n\n"
      html.push(one_video)
    end
    @bookmarks = html.join('')
    erb :vids
  end
end

post '/login' do
  if params[:u] == '' # TODO obv remove this if statement at some point
    session[:username] = "maxwell.jacobson@gmail.com"
    session[:password] = "layabout"
  else
    session[:username] = params[:u]
    session[:password] = params[:pw]
  end
  redirect '/'
end

get '/logout' do
  session[:username] = nil
  session[:password] = nil
  redirect '/'
end

get '/:page' do
  if File.exists?('views/'+params[:page]+'.erb')
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