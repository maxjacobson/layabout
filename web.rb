require 'sinatra'
require 'instapaper_full'
require 'oembed'
require 'pony'
require 'kramdown'
require 'mail'
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

get '/faq' do
  @title = "Layabout"
  @subtitle = "FAQ"
  @display_header = false
  erb :faq
end

get '/' do
  if session[:username].nil? or session[:password].nil?
    @title = "Layabout"
    @subtitle = "Log in to Instapaper"
    @display_header = false
    erb :login#, :layout => false
  else
    redirect '/page/1'
  end
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
  videos_per_page = 5.0
  amount_of_pages = (amount_of_videos / videos_per_page).ceil
  last_video = (current_page * videos_per_page).to_i
  first_video = (last_video - videos_per_page).to_i + 1
  if last_video > amount_of_videos
    last_video = amount_of_videos
  end

  video_subset_index = Hash.new
  for y in first_video..last_video
    video_subset_index[y] = true
  end

  # TODO get rid of oembed it's slow and buggy
  html = Array.new

  nav = String.new
  if current_page == 1
    nav << "      <div class=\"pagination\">\n        <ul>\n          <li class=\"disabled\"><a href=\"#\">Previous page</a></li>\n"
  else
    nav << "      <div class=\"pagination\">\n        <ul>\n          <li><a href=\"/page/#{current_page-1}\">Previous page</a></li>\n"
  end
  for i in 1..amount_of_pages
    if i == current_page
      nav << "          <li class=\"active\"><a href=\"/page/#{i}\">#{i}</a></li>\n"
    else
      nav << "          <li><a href=\"/page/#{i}\">#{i}</a></li>\n"
    end
  end
  if current_page == amount_of_pages
    nav << "          <li class=\"disabled\"><a href=\"#\">Next page</a></li>\n        </ul>\n      </div>\n\n"
  else
    nav << "          <li><a href=\"/page/#{current_page+1}\">Next page</a></li>\n        </ul>\n      </div>\n\n"
  end

  if video_links.length > videos_per_page
    html.push(nav)
  end
  html.push("<form action=\"/add\" method=\"POST\"><input type=\"text\" name=\"url\" placeholder=\"Add url to Instapaper...\"></input></form>\n")

  if video_links.length == 0
    html.push("<hr /><p><span class=\"label label-important\">No videos!</span></p>\n")
  end

  index_checker = 1
  video_links.each_value do |link|
    if video_subset_index.member?(index_checker)
      html.push(video_to_html(link))
    end
    index_checker+=1
  end

  if video_links.length > videos_per_page
    html.push(nav)
  end

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
  ip = InstapaperFull::API.new :consumer_key => app_key, :consumer_secret => app_secret
  if ip.authenticate(session[:username], session[:password])
    if session[:username] != "maxwell.jacobson@gmail.com"
      Pony.mail({:to => 'max+layabout@maxjacobson.net',:subject => 'Someone else logged in!', :via => :smtp, :via_options => { :address => 'smtp.gmail.com', :port => '587', :enable_starttls_auto => true, :user_name => 'max@maxjacobson.net', :password => '3118milola', :authentication => :plain, :domain => "localhost.localdomain"}})
      puts "Logging in as #{session[:username]}"
    end
    redirect '/page/1'
  else
    session.clear
    redirect '/'
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/switch-to-folder/:id' do
  session[:folder] = params[:id].to_s
  redirect '/page/1'
end

get '/like/:id' do
  perform_action({:action => :like, :id => params[:id].to_i})
  redirect back
end

get '/unlike/:id' do
  perform_action({:action => :unlike, :id => params[:id].to_i})
  redirect back
end

get '/archive/:id' do
  perform_action({:action => :archive, :id => params[:id].to_i})
  redirect back
end

get '/delete/:id' do
  perform_action({:action => :delete, :id => params[:id].to_i})
  redirect back
end

get '/like-and-archive/:id' do
  perform_action({:action => :like_and_archive, :id => params[:id].to_i})
  redirect back
end

get '/unlike-and-delete/:id' do
  perform_action({:action => :unlike_and_delete, :id => params[:id].to_i})
  redirect back
end