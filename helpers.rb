def get_cipher
  # change the key to alter the encryption
  # probably replace this with something less goofy
  Gibberish::AES.new("b34rvssh4rk")
end

def encrypt(pw)
  cipher = get_cipher()
  pw = "anything" if pw == "" # empty strings break the encrypter, BUT instapaper will accept anything if someone's pw is ""
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
  ip = session[:ip]

  @videos = (if folder_id == :readlater
    ip.bookmarks_list(:limit => 500)
  else
    ip.bookmarks_list(:limit => 500, :folder_id => folder_id)
  end).map do |link|
    if link['type'] == 'bookmark' # filters out the first two irrelevant items
      snob = FilmSnob.new(link['url'])
      if snob.watchable?
        link.tap do |link|
          link['video_id'] = snob.id
          link['title'] = cleanup_title link['title']
          link['vid_site'] = snob.site
          link['description'] = make_clicky link['description']
        end
      end
    end
  end.compact

  session[:folder_id] = folder_id
  session[:folder_title] = folder_title
  session[:folders_list] ||= ip.folders_list.map do |folder|
    folder.tap { |f| f["clean_title"] = f["title"].gsub(/\s/, '-') }
  end
  haml :videos
end

def current_link
  Link.new(params[:id], session[:ip])
end

