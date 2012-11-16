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
  if session[:username].nil? or session[:password].nil?
    @title = "Layabout"
    @subtitle = "Log in to Instapaper"
    erb :login
  else
    redirect '/page/1'
  end
end

get '/page/:num' do
  
  app_key = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  app_secret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"  
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
  
  current_page = params[:num].to_i
  session[:current_page] = current_page
  amount_of_videos = video_links.length
  videos_per_page = 5.0
  amount_of_pages = (amount_of_videos / videos_per_page).ceil
  # puts "With #{amount_of_videos} videos and #{videos_per_page.to_i} videos per page, there should be #{amount_of_pages} pages."
  last_video = (current_page * videos_per_page).to_i
  first_video = (last_video - videos_per_page).to_i + 1
  if last_video > amount_of_videos
    last_video = amount_of_videos
  end
  # puts "Page #{current_page} will feature videos #{first_video}-#{last_video}"
  
  video_subset_index = Hash.new
  for y in first_video..last_video
    video_subset_index[y] = true
  end

  # puts video_subset_index

  html = Array.new  
  index_checker = 1
  video_links.each_value do |link|
    if video_subset_index.member?(index_checker)
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
    index_checker+=1
  end

  nav = String.new
  if current_page == 1
    nav << "<div class=\"pagination\">\n  <ul>\n    <li class=\"disabled\"><a href=\"#\">Prev</a></li>\n"
  else
    nav << "<div class=\"pagination\">\n  <ul>\n    <li><a href=\"/page/#{current_page-1}\">Prev</a></li>\n"
  end
  for i in 1..amount_of_pages
    if i == current_page
      nav << "    <li class=\"active\"><a href=\"/page/#{i}\">#{i}</a></li>\n"
    else
      nav << "    <li><a href=\"/page/#{i}\">#{i}</a></li>\n"
    end
  end
  if current_page == amount_of_pages
    nav << "    <li class=\"disabled\"><a href=\"#\">Next</a></li>\n  </ul>\n</div>\n"
  else
    nav << "    <li><a href=\"/page/#{current_page+1}\">Next</a></li>\n  </ul>\n</div>\n"
  end
    
    
  html.push(nav)
  @bookmarks = html.join('')
  
  
  

  @title = "Layabout"
  @subtitle = "Watch (#{amount_of_videos})"
  erb :vids
end




post '/login' do
  session[:username] = params[:u]
  session[:password] = params[:pw]
  puts "Logging in as #{params[:u]}"
  redirect '/page/1'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/like-and-archive/:id' do
  session[:action_id] = params[:id]
  session[:action] = 'like-and-archive'
  redirect '/page/' + session[:current_page].to_s
end

get '/unlike-and-delete/:id' do
  session[:action_id] = params[:id]
  session[:action] = 'unlike-and-delete'
  redirect '/page/' + session[:current_page].to_s
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
  redirect '/page/' + session[:current_page].to_s# + '/#' + session[:action_id]
end

get '/archive/:id' do
  session[:action_id] = params[:id]
  session[:action] = 'archive'
  redirect '/page/' + session[:current_page].to_s
end

get '/delete/:id' do
  session[:action_id] = params[:id]
  session[:action] = 'delete'
  redirect '/page/' + session[:current_page].to_s
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
