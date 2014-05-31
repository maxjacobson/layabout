begin
  if current_user.present?
    # FIXME can I use film instead of @film?
    if film.watchable?
      json.watchable true
      json.readable false
      json.html film.html
    else
      json.watchable false
      json.readable true
      json.html render 'modal.html.erb'#current_user.instapaper.text @bookmark
    end
  else
    json.watchable false
    json.reason "Sorry, you must be logged in"
  end
rescue Exception => e
  json.watchable false
  json.reason e.to_s
end
