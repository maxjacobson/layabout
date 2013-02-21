def get_cipher
  # change the key to alter the encryption
  Gibberish::AES.new("b34rvssh4rk")
end

def encrypt(pw)
  cipher = get_cipher()
  pw = "anything" if pw == ""
  cipher.enc(pw)
end

def decrypt(pw)
  cipher = get_cipher()
  cipher.dec(pw)
end

def get_ip
  InstapaperFull::API.new :consumer_key => "CAylHIEIhqdEI0LX4GQp0RcUoLkLQml0VfKIoaRyueKpwgjMop",
    :consumer_secret => "UYdf9isHWJTJtBjXQvbwTSYQU4Q8kyqm2x7l3jBLL3Kjju8Nhg"
end

def grok_url (url)
  return true, :youtube if url =~ /youtube.com/
  return true, :vimeo_mobile if url =~ /vimeo.com\/m\//
  return true, :vimeo if url =~ /vimeo.com/
  return true, :hulu if url =~ /hulu.com/
  return true, :youtube_mobile if url =~ /youtu.be/
  return false, :none
end

def load_videos(folder_id, folder_title) # folder id
  ip = get_ip()
  ip.authenticate(session[:username], decrypt(session[:password]))
  video_links = Array.new
  if folder_id == :readlater
    all_links = ip.bookmarks_list(:limit => 500)
  else
    all_links = ip.bookmarks_list(:limit => 500, :folder_id => folder_id)
  end
  all_links.each do |link|
    if link["type"] == "bookmark" # filters out the first two irrelevant items
      is_video, vid_site = grok_url link["url"]
      if is_video == true
        link["vid_site"] = vid_site
        # link["embed"] = get_embed link["url"]
        video_links.push link
      end
    end
  end
  @videos = video_links
  session[:folder_id] = folder_id
  session[:folder_title] = folder_title
  session[:folders_list] = ip.folders_list if session[:folders_list].nil?
  haml :videos
end

def perform_action(i) # i for instructions
  ip = get_ip()
  ip.authenticate(session[:username], decrypt(session[:password]))
  action = i[:action]
  if action == :like
    ip.bookmarks_star({"bookmark_id" => i[:id]})
  elsif action == :unlike
    ip.bookmarks_unstar({"bookmark_id" => i[:id]})
  elsif action == :archive
    ip.bookmarks_archive({"bookmark_id" => i[:id]})
  elsif action == :unarchive
    ip.bookmarks_unarchive({"bookmark_id" => i[:id]})
  elsif action == :delete
    ip.bookmarks_delete({"bookmark_id" => i[:id]})
  elsif action == :like_and_archive
    ip.bookmarks_star({"bookmark_id" => i[:id]})
    ip.bookmarks_archive({"bookmark_id" => i[:id]})
  elsif action == :unlike_and_delete
    ip.bookmarks_unstar({"bookmark_id" => i[:id]})
    ip.bookmarks_delete({"bookmark_id" => i[:id]})
  elsif action == :add_url
    ip.bookmarks_add({"url" => i[:url]})
  elsif action == :move
    ip.bookmarks_move({"bookmark_id" => i[:id], "folder_id" => i[:folder_id]})
  end
end