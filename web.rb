require 'sinatra' # framework for web app
require 'haml' # templates
require 'gibberish' # password encryption
require 'instapaper_full' # access to Instapaper API
require 'film_snob' # video URL parser
require 'oembed' # video URL -> HTML embed code
require_relative 'link.rb'    # an Instapaper link
require_relative 'helpers.rb' # helper methods

enable :sessions
set :dump_errors, false
set :show_exceptions, false
set :views, File.dirname(__FILE__) + "/views"

get '/' do
  if session[:username].nil? or session[:password].nil?
    if session[:loginmessage].nil? == false
      @loginmessage = session[:loginmessage]
      session.clear
    end
    haml :login
  else
    load_videos(:readlater, "Read Later")
  end
end

post '/' do

  u = params[:u]  # username as entered
  pw = params[:pw] # password as entered

  if u.downcase == "nilsen" and pw.downcase == "nilsen" # made case insensitive because of iOS
    session[:username] = "maxwell.jacobson@gmail.com"
    session[:password] =  encrypt "layabout" # still my instapaper password...
  else
    session[:username] = u
    session[:password] = encrypt pw
  end

  ip = get_ip() # method in helpers.rb
  if ip.authenticate(session[:username], decrypt(session[:password]))
    if ip.options[:subscription_is_active] == "1" # can use site
      session[:ip] = ip
      load_videos(:readlater, "Read Later")
    else # can't use site unless they subscribe. break it to them easy
      session.clear
      redirect '/subscribe'
    end
  else # bad login info
    session.clear
    session[:loginmessage] = "Bad login info" # will show up above the login form
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

get '/subscribe' do
  haml :subscribe
end

get '/folder/:id/:title' do
  if session[:username].nil?
    redirect '/'
  else
    load_videos(params[:id], params[:title].gsub(/\-/, ' '))
  end
end

get '/like/:id' do
  current_link.like!
  "Liked #{params[:id]}"
end

get '/unlike/:id' do
  current_link.unlike!
  "Disliked #{params[:id]}"
end

get '/archive/:id' do
  current_link.archive!
  "Archived #{params[:id]}"
end

get '/delete/:id' do
  current_link.delete!
  "Deleted #{params[:id]}"
end

get '/like-and-archive/:id' do
  current_link.like_and_archive!
  "Liked and archived #{params[:id]}"
end

get '/unlike-and-delete/:id' do
  current_link.unlike_and_delete!
  "Unliked and deleted #{params[:id]}"
end

get '/move/:id/to/:folder' do
  params[:folder] == 'readlater' ? current_link.unarchive! : current_link.move_to(params[:folder])
  "Moved #{params[:id]} to folder: #{params[:folder]}"
end

get '/embedcode/:site/:id' do
  embedcode = get_embed params[:site].to_sym, params[:id]
  if embedcode.nil? or embedcode == ""
    "Video could not be loaded. It may have embedding disabled."
  else
    haml embedcode, :layout => false
  end
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
