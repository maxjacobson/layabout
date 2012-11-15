def cap_first (s)
  # this code via stack overflow http://stackoverflow.com/questions/2646709/capitalize-only-first-character-of-string-and-leave-others-alone-rails
  return s.slice(0,1).capitalize + s.slice(1..-1)
end

def is_video (url)
  if url =~ /youtube.com/
    return [true, "youtube"]
  elsif url=~ /vimeo.com\/m\//
    return [true, "vimeo-mobile"]
  elsif url =~ /vimeo.com/
    return [true, "vimeo"]
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
  s.gsub!(/@[A-Za-z0-9_]+/, '<a href="http://twitter.com/\0">\0</a>')
  s.gsub!(/twitter.com\/@/, 'twitter.com/')
  return s
end

def youtube_cleanup (url)
  if url =~ /embed\//
    id = url.match(/\/embed\/[A-Za-z0-9_-]+/).to_s
    id.gsub!(/\/embed\//,'v=')
  else
    id = url.match(/v=[A-Za-z0-9_-]+/).to_s
  end
  url = 'http://youtube.com/watch?' + id
  return url
end

def vimeo_cleanup (url)
  url.gsub!(/vimeo.com\/m\//,'vimeo.com/')
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
  title.gsub!(/Watch ([A-Za-z0-9 ]+) \| ([A-Za-z0-9 ]+) online \| Free \| Hulu/, '\1: \2')
  title.gsub!(/^[ \t\n]+/, '')
  title.gsub!(/[ \t\n]+$/, '')
  return title
end