require 'sinatra'
require 'instapaper_full'
require 'oembed'
require 'pony'
require 'kramdown'
require 'mail'
require 'sass'
require_relative 'helpers.rb'

enable :sessions
set :dump_errors, false
set :show_exceptions, false

error 404 do
  @title= "Layabout"
  @subtitle = "404"
  @display_header = false
  erb :'404'
end

error do
  @title= "Layabout"
  @subtitle = "500"
  @display_header = false
  session[:folder] = nil
  session[:action] = nil
  session[:action_id] = nil
  session[:current_page] = nil
  erb :'500'
end

get '/num_of_pages' do
  if session[:num_of_pages].nil? == false
    erb session[:num_of_pages].to_s, :layout => false
  end
end

get '/num_of_videos' do
  if session[:num_of_videos].nil? == false
    erb session[:num_of_videos].to_s, :layout => false
  end
end

get '/about' do
  @title = "Layabout"
  @subtitle = "about"
  @display_header = false
  erb :about
end

get '/faq' do
  redirect '/about'
end

get '/' do
  if session[:username].nil? or session[:password].nil?
    @title = "Layabout"
    @subtitle = "Log in to Instapaper"
    @display_header = false
    erb :login#, :layout => false
  else
    if session[:num_of_videos].nil? == false
      @title = "(#{session[:num_of_videos]}) "
    else
      @title = ""
    end
    @subtitle = "Layabout"
    session[:folder] = "main"
    erb :videos
  end
end

get '/folder/:id' do
  session[:folder] = params[:id].to_s
  if session[:username].nil? or session[:password].nil? or session[:folder].to_sym == :main
    redirect '/'
  else
    if session[:num_of_videos].nil? == false
      @title = "(#{session[:num_of_videos]}) "
    else
      @title = ""
    end
    @subtitle = "Layabout"
    erb :videos
  end
end

get '/css/style.css' do
  scss :style
end

get '/page/:num' do

  if session[:username].nil? or session[:password].nil?
    redirect '/'
  end

  app_key = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  app_secret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"
  ip = InstapaperFull::API.new :consumer_key => app_key, :consumer_secret => app_secret
  ip.authenticate(session[:username], session[:password])
  folders_list = ip.folders_list

  if session[:folder].nil?
    session[:folder] = "main"
    all_links = ip.bookmarks_list(:limit => 500)
    folder_name = ""
  else
    all_links = ip.bookmarks_list(:limit => 500, :folder_id => session[:folder])
    folders_list.each do |folder|
      if folder.has_value?(session[:folder].to_i)
        folder_name = " #{folder["title"]}"
      end
    end
  end


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

  current_page = params[:num].to_i
  session[:current_page] = current_page
  amount_of_videos = video_links.length
  session[:num_of_videos] = amount_of_videos
  videos_per_page = 5.0
  num_page_links_to_include_in_nav = 5
  amount_of_pages = (amount_of_videos / videos_per_page).ceil
  session[:num_of_pages] = amount_of_pages
  last_video = (current_page * videos_per_page).to_i
  first_video = (last_video - videos_per_page).to_i + 1
  if last_video > amount_of_videos
    last_video = amount_of_videos
  end

  video_subset_index = Hash.new
  for y in first_video..last_video
    video_subset_index[y] = true
  end

  html = Array.new

  nav = String.new
  navhash = Hash.new
  nav << "<ul class=\"pager\">\n  <li class=\"previous#{ " disabled" if current_page == 1}\"><a href=\"#{current_page == 1 ? "#" : "/page/#{current_page-1}"}\">Page--</a></li>\n  <li class=\"next#{" disabled" if current_page == amount_of_pages}\"><a href=\"#{current_page == amount_of_pages ? "#" : "/page/#{current_page+1}"}\">Page++</a></li>\n</ul>\n"
  nav << "<div class=\"pagination\">\n"

  nav << "<ul>\n"
  # for i in 1..amount_of_pages
  #   nav << "<li#{" class=\"active\"" if i == current_page} id=\"pagelink#{i}\"><a href=\"/page/#{i}\">#{i}</a></li>\n"
  # end

  # # all the following commented out because I'm trying something else. if you end up wanting to use this again, you'll need to comment out some stuff above
  #
  pages_to_include = Hash.new
  if amount_of_pages < num_page_links_to_include_in_nav
    for i in 1..amount_of_pages
      pages_to_include[i] = true
    end
  else
    pages_to_include[1] = true
    pages_to_include[amount_of_pages] = true
    pages_to_include[current_page] = true
    x = 1
    while pages_to_include.length < num_page_links_to_include_in_nav
      pages_to_include[current_page + x] = true if (current_page + x) < amount_of_pages
      pages_to_include[current_page - x] = true if (current_page - x) > 1
      x += 1
    end
  end

  # for i in 1..amount_of_pages
  #   navhash[i] = "<li#{" class=\"active\"" if i == current_page}><a href=\"/page/#{i}\">#{i}</a></li>\n"
  # end

  dotdotdot_triggered1 = false
  dotdotdot_triggered2 = false
  for i in 1..amount_of_pages
    if pages_to_include[i] == true
      nav << "<li#{" class=\"active\"" if i == current_page}><a href=\"/page/#{i}\">#{i}</a></li>\n"
    else
      nav << "<li class=\"hide_on_mobile\"><a href=\"/page/#{i}\">#{i}</a></li>\n"
      if i < current_page and dotdotdot_triggered1 == false
        nav << "<li class=\"active dotdotdot\"><a href=\"#\">...</a></li>\n"
        dotdotdot_triggered1 = true
      elsif i > current_page and dotdotdot_triggered2 == false
        nav << "<li class=\"active dotdotdot\"><a href=\"#\">...</a></li>\n"
        dotdotdot_triggered2 = true
      end
    end
  end

  nav << "</ul>\n</div>\n"

  html.push("<div id=\"just_videos\">\n")

  html.push("<hr /><p><span class=\"label label-important\">No videos!</span> Consider switching folders using the dropdown menu in the top right or go find some more videos.</p>\n") if video_links.length == 0

  index_checker = 1
  video_links.each_value do |link|
    html.push(video_to_html(link)) if video_subset_index.member?(index_checker)
    index_checker+=1
  end
  html.push("</div>\n")

  # html.push(nav) if video_links.length > videos_per_page

  @bookmarks = html.join('')

  if session[:folder] == "main"
    @title = "Layabout"
  else
    @title = "Layabout - #{folder_name}"
  end

  @subtitle = "Watch (#{amount_of_videos})"
  erb @bookmarks
end

get '/search' do
  # paginate results
  # display number of results
  # display which folder it's in?
  # be more fuzzy... multi word queries shouldn't require an exact match
  @title = "Layabout"
  results_count = 0
  html = Array.new
  html.push("<p>Search is a new feature and is missing several things you might expect like fuzzy matching ('the beatles' wouldn't match 'beatles') or pagination. Working on it.</p>\n")
  q = params[:q]
  r = Regexp.new(q, true)
  app_key = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  app_secret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"
  ip = InstapaperFull::API.new :consumer_key => app_key, :consumer_secret => app_secret
  ip.authenticate(session[:username], session[:password])
  all_folders = Array.new
  all_folders.push(ip.bookmarks_list(:limit => 500))
  ip.folders_list.each do |folder|
    all_folders.push(ip.bookmarks_list(:limit => 500, :folder_id => folder["folder_id"]))
  end
  all_folders.each do |folder|
    folder.each do |link|
      if link["title"] =~ r or link["url"] =~ r or link["description"] =~ r
        checker = is_video(link["url"])
        if checker[0] == true
          results_count += 1
          link["vid_site"] = checker[1]
          html.push(video_to_html(link))
        end
      end
    end
  end
  if results_count == 0
    html.push("<p>No results found for \"#{q}\"\n")
  end
  @subtitle = "#{results_count} results for \"#{q}\""
  erb html.join('')
end

post '/add' do
  url = params[:url]
  perform_action({:action => :add_url, :url => url})
  redirect back
end

post '/login' do
  session[:username] = params[:u]
  session[:password] = params[:pw]
  app_key = "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop"
  app_secret = "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"


  if session[:username] == "nilsen" and session[:password] == "nilsen"
    session[:username] = "maxwell.jacobson@gmail.com"
    session[:password] = "layabout"
  end


  ip = InstapaperFull::API.new :consumer_key => app_key, :consumer_secret => app_secret
  if ip.authenticate(session[:username], session[:password])
    if session[:username] != "maxwell.jacobson@gmail.com"
      Pony.mail({:to => 'max+layabout@maxjacobson.net',:subject => 'Someone else logged in!', :via => :smtp, :via_options => { :address => 'smtp.gmail.com', :port => '587', :enable_starttls_auto => true, :user_name => 'max@maxjacobson.net', :password => '3118milola', :authentication => :plain, :domain => "localhost.localdomain"}})
      puts "Logging in as #{session[:username]}"
    end
    redirect '/'
  else
    session.clear
    redirect '/'
  end
end

get '/logout' do
  session.clear
  redirect '/'
end



get '/like/:id' do
  perform_action({:action => :like, :id => params[:id].to_i})
  "You like #{params[:id]}"
end

get '/unlike/:id' do
  perform_action({:action => :unlike, :id => params[:id].to_i})
  "You unlike #{params[:id]}"
end

get '/archive/:id' do
  perform_action({:action => :archive, :id => params[:id].to_i})
  "You archive #{params[:id]}"
end

get '/delete/:id' do
  perform_action({:action => :delete, :id => params[:id].to_i})
  "You delete #{params[:id]}"
end

get '/like-and-archive/:id' do
  perform_action({:action => :like_and_archive, :id => params[:id].to_i})
  "You like-and-archive #{params[:id]}"
end

get '/unlike-and-delete/:id' do
  perform_action({:action => :unlike_and_delete, :id => params[:id].to_i})
  "You unlike-and-delete #{params[:id]}"
end
