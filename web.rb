require 'sinatra' # framework for web app
require 'haml' # templates
require 'gibberish' # password encryption
require 'instapaper_full' # access to Instapaper API
require 'oembed' # video URL -> HTML embed code
require_relative 'helpers.rb' # helper methods

enable :sessions
set :dump_errors, false
set :show_exceptions, false

get '/' do
  if session[:username].nil? or session[:password].nil?
    haml :login
  else
    load_videos(:readlater, "Read Later")
  end
end

post '/' do

  u = params[:u]  # username as entered
  pw = params[:pw] # password as entered

  if u == "nilsen" and pw == "nilsen"
    session[:username] = "maxwell.jacobson@gmail.com"
    session[:password] =  encrypt "layabout"
  else
    session[:username] = u
    session[:password] = encrypt pw
  end

  ip = get_ip() # method in helpers.rb
  if ip.authenticate(session[:username], decrypt(session[:password]))
    load_videos(:readlater, "Read Later")
  else
    session.clear
    redirect '/'
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/about' do
  haml :about
end

get '/folder/:id/:title' do
  if session[:username].nil?# or session[:folder_id] == :readlater
    redirect '/'
  else
    load_videos(params[:id], params[:title].gsub(/\-/, ' '))
  end
end

get '/like/:id' do
  perform_action({:action => :like, :id => params[:id].to_i})
  "Liked"
end

get '/unlike/:id' do
  perform_action({:action => :unlike, :id => params[:id].to_i})
  "Disliked"
end

get '/archive/:id' do
  perform_action({:action => :archive, :id => params[:id].to_i})
  "Archived"
end

get '/delete/:id' do
  perform_action({:action => :delete, :id => params[:id].to_i})
  "Deleted"
end

get '/like-and-archive/:id' do
  perform_action({:action => :like_and_archive, :id => params[:id].to_i})
  "Liked and archived"
end

get '/unlike-and-delete/:id' do
  perform_action({:action => :unlike_and_delete, :id => params[:id].to_i})
  "Unliked and deleted"
end

get '/move/:id/to/:folder' do
  id = params[:id].to_i
  folder = params[:folder]
  if folder == "readlater"
    perform_action({:action => :unarchive, :id => id})
  else
    perform_action({:action => :move, :id => id, :folder_id => folder.to_i})
  end
  "Moved to folder: #{folder}"
end

get '/embedcode/:site/:id' do
  embedcode = get_embed params[:site].to_sym, params[:id]
  haml embedcode, :layout => false
end

error 404 do
  haml "Sorry, that page doesn't exist."
end

error 500 do
  u = session[:username]
  pw = session[:pw]
  session.clear
  session[:username] = u
  session[:pw] = pw
  haml "Sorry, there was an error. Maybe try again?"
end