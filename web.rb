require 'sinatra'
require 'instapaper_full'
require 'oembed'
require_relative 'helpers.rb'

enable :sessions
set :dump_errors, false
set :show_exceptions, false

error 404 do
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
      elsif session[:action] == "like-and-archive"
        ip.bookmarks_star(the_link)
        ip.bookmarks_archive(the_link)
        puts "You liked and archived #{the_link["title"]}"
        video_links.delete(action_id)
      elsif session[:action] == "unlike-and-delete"
        ip.bookmarks_unstar(the_link)
        ip.bookmarks_delete(the_link)
        puts "You unliked and deleted #{the_link["title"]}"
        video_links.delete(action_id)
      end
      session[:action] = nil
      session[:action_id] = nil
    end

    ## TODO thought: instead of querying instapaper after this kind of thing, just intelligently modify the html array and send it to a fresh :erb???

    html = Array.new
    if video_links.length == 1
      html.push("<p>There is one video.</p>\n")
    else
      html.push("<p>There are #{video_links.length} videos.</p>\n")
    end
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
      one_video << "        <h2><a href=\"#{the_url}\" id=\"#{link["bookmark_id"]}\">#{title_cleanup(resource.title)}&rarr;</a></h2>\n"
      one_video << "        <p>#{resource.html}</p>\n"
      one_video << "        <p><code>#{the_url}</code></p>\n"

      if link["description"] != ""
        one_video << "        <p>#{make_clicky(link["description"])}</p>\n"
      end

      if link["starred"] == "0"
        one_video << "        <p><a href=\"/like/#{link["bookmark_id"]}\"><button class=\"btn btn-primary\">Like <i class=\"icon-heart icon-white\"></i></button></a> "
        one_video << "<a href=\"/like-and-archive/#{link["bookmark_id"]}\"><button class=\"btn btn-primary\">Like and Archive <i class=\"icon-heart icon-white\"></i> <i class=\"icon-folder-open icon-white\"></i></button></a> "
      elsif link["starred"] == "1"
        one_video << "        <p><a href=\"/like/#{link["bookmark_id"]}\"><button class=\"btn btn-success\">Unlike <i class=\"icon-heart icon-white\"></i></button></a> "
      end
      one_video << "<a href=\"/archive/#{link["bookmark_id"]}\"><button class=\"btn btn-warning\">Archive <i class=\"icon-folder-open icon-white\"></i></button></a> "

      if link["starred"] == "0"
        one_video << "<a href=\"/delete/#{link["bookmark_id"]}\"><button class=\"btn btn-danger\">Delete <i class=\"icon-remove icon-white\"></i></button></a></p>\n"
      elsif link["starred"] == "1"
        one_video << "<button class=\"btn btn-danger disabled\">Delete <i class=\"icon-remove icon-white\"></i></button> "
        one_video << "<a href=\"/unlike-and-delete/#{link["bookmark_id"]}\"><button class=\"btn btn-danger\">Unlike and Delete <i class=\"icon-remove icon-white\"></i></button></a></p>\n"
      end


      one_video << "      </div>\n\n"
      html.push(one_video)
    end
    @bookmarks = html.join('')
    erb :vids
  end
end

post '/login' do
  session[:username] = params[:u]
  session[:password] = params[:pw]
  redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/like-and-archive/:id' do
  session[:action_id] = params[:id]
  session[:action] = 'like-and-archive'
  redirect '/'
end

get '/unlike-and-delete/:id' do
  session[:action_id] = params[:id]
  session[:action] = 'unlike-and-delete'
  redirect '/'
end

get '/like/:id' do
  # # attempt at ajaxy implementation...
  # app_key = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  # app_secret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"
  # ip = InstapaperFull::API.new :consumer_key => app_key, :consumer_secret => app_secret
  # ip.authenticate(session[:username], session[:password])
  # all_links = ip.bookmarks_list(:limit => 500)
  # all_links.each do |h|
  #   if h.has_value?(params[:id])
  #     if h["starred"] == "0"
  #       ip.bookmarks_star(h)
  #       puts "You liked #{h["title"]}"
  #     elsif h["starred"] == "1"
  #       ip.bookmarks_unstar(h)
  #       puts "You unliked #{h["title"]}"
  #     end
  #   end
  # end

  session[:action_id] = params[:id]
  session[:action] = 'star'
  redirect '/#' + session[:action_id]
end

get '/archive/:id' do
  session[:action_id] = params[:id]
  session[:action] = 'archive'
  redirect '/'
end

get '/delete/:id' do
  session[:action_id] = params[:id]
  session[:action] = 'delete'
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
