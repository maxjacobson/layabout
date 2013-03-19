puts = (str) -> console.log str # https://alpha.app.net/maxjacobson/post/3686793
delay = (s, func) -> setTimeout func, s*1000 # http://stackoverflow.com/a/6460151

underline_current_folder = (id) -> $("##{id}").css "text-decoration", "underline" # why is this a method?

update_count = (num) ->
  document.title = "(#{num}) Layabout"
  $("#vid_count").text(num)
  if num is 0
    $("#messages").text "No more videos!"
    $("#more_videos").remove() # rid of the load more button

load_more_vids = (vids_showing, num_to_load, vid_count, speed) ->
  queue = $(".video.hiding")
  if vid_count - vids_showing > num_to_load
    queue.slice(0, num_to_load).slideToggle speed, ->
      $(this).removeClass 'hiding'
    console.log "Showing #{vids_showing + num_to_load} of #{vid_count} videos"
    return vids_showing + num_to_load # new total of visible videos
  else
    $("#messages").text "You've reached the bottom of this folder!" if $("#messages").text() is ""
    $("#more_videos").slideToggle 'fast' # gets rid of button
    queue.slideToggle speed, ->
      $(this).removeClass 'hiding'
    console.log "Showing all #{vid_count} videos"
    return vid_count # new total of visible videos

remove_video = (video_id) ->
  video = $(".video##{video_id}")
  if Math.random() > 0.5
    video.addClass "animated bounceOutLeft"
  else
    video.addClass "animated bounceOutRight"
  delay 1, ->
    video.remove()