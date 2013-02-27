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
  # support hulu short urls
  if url =~ /youtube\.com\/embed\//
    id = url.match(/\/embed\/([A-Za-z0-9_-]+)/)[1].to_s
    site = :youtube
  elsif url =~ /youtube\.com/
    id = url.match(/v=([A-Za-z0-9_-]+)/)[1].to_s
    site = :youtube
  elsif url =~ /youtu\.be/
    id = url.match(/(http:\/\/youtu.be\/)([A-Za-z0-9\-_]+)/)[2].to_s
    site = :youtube
  elsif url =~ /vimeo\.com\/m\//
    id = "todo"
    site = :vimeo
  elsif url =~ /vimeo\.com/
    # https://vimeo.com/59777392
    id = url.match(/vimeo\.com\/([\d]+)/)[1].to_s
    site = :vimeo
  elsif url =~ /hulu\.com\/watch/
    id = url.match(/watch\/([\d]+)/)[1].to_s
    site = :hulu
  else
    return false, false, false
  end
  return true, site, id
end

def cleanup_title (title)
  # because it's needless clutter
  title.gsub!(/ - YouTube/, '')
  title.gsub!(/YouTube - /, '')
  title.gsub!(/ on Vimeo/, '')
  title.gsub!(/Watch (.+) \| (.+) online \| Free \| Hulu/, '\1: \2')
  title.gsub!(/Watch (.+) online \| Free \| Hulu/, '\1')
  title.gsub!(/^[\s\t\n]+/, '')
  title.gsub!(/[\s\t\n]+$/, '')
  return title
end

def make_clicky (str)
  str.gsub!(/\w*(:\/\/)\w*.[\w#?%=\/]+/, '<a href="\0">\0</a>') # makes URLs clickable
  str.gsub!(/@([A-Za-z0-9_]+)/, '<a href="https://twitter.com/\1">@\1</a>') # makes twitter handles clickable
  str.gsub!(/\#([\w\d]+)/, '<a href="https://twitter.com/search?q=%23\1">#\1</a>') # makes hashtags clickable
  return str
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
      is_video, vid_site, video_id = grok_url link["url"]
      if is_video == true
        link["video_id"] = video_id
        link["title"] = cleanup_title link["title"] # prob not necessary
        link["vid_site"] = vid_site
        link["description"] = make_clicky link["description"]
        video_links.push link
      end
    end
  end
  @videos = video_links
  session[:folder_id] = folder_id
  session[:folder_title] = folder_title
  if session[:folders_list].nil?
    folders_list = ip.folders_list
    for i in 0...folders_list.length
      folders_list[i]["clean_title"] = folders_list[i]["title"].gsub(/\s/,'-')
    end
    session[:folders_list] = folders_list
  end
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

def get_embed (vid_site, id)
  if vid_site == :youtube
    url = "http://www.youtube.com/watch?v=#{id}"
    return OEmbed::Providers::Youtube.get(url).html
  elsif vid_site == :vimeo
    url = "http://www.vimeo.com/#{id}"
    return OEmbed::Providers::Vimeo.get(url, maxwidth: "500", portrait: false, byline: false, title: false).html
  elsif vid_site == :hulu
    url = "http://www.hulu.com/watch/#{id}"
    return OEmbed::Providers::Hulu.get(url).html
  else
    return "<p>Failed to get embed code</p>"
  end
end
