#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require_tree .
#= require_self

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

###
  Note to anyone who may be viewing the JavaScript of this web page:
  This was written in CoffeeScript and so some stuff may look weird in the compiled version.
  I don't understand why 'return' is in there so much. I never did that when I was writing JavaScript.
  I'd like to figure out source maps so this can point to the CS file, but I have to go eat I'm so hungry.
###

$(document).on 'ready page:load', ->

  # I want to use [this plugin](http://css-tricks.com/fluid-width-youtube-videos/)
  # but it's in js, so I've adapted it to CoffeeScript and made it work with all iframes,
  # not just youtube ones. dope plugin chris!

  $allVideos = $("iframe")
  $fluidEl = $("#yield")
  $allVideos.each ->
    $(this).data('aspectRatio', this.height / this.width).removeAttr('height').removeAttr('width')
  $(window).resize ->
    newWidth = $fluidEl.width()
    $allVideos.each ->
      $el = $(this)
      $el.width(newWidth).height(newWidth * $el.data('aspectRatio'))
  $(window).resize()


  vid_count = parseInt $("#vid_count").text() # provided by the videos.haml file
  if not navigator.mimeTypes["application/x-shockwave-flash"] # no flash, hide hulu videos
    hulu_vids = $(".hulu")
    num_hulu_vids = hulu_vids.length
    vid_count -= num_hulu_vids
    puts "Removing #{num_hulu_vids} hulu videos"
    hulu_vids.remove()
  height_diff = $(document).height() - $("body").height()
  $("#buffer2").css "height", "#{height_diff - 50}px" if height_diff > 0 # pushes footer to bottom (sometimes too far)
  document.title = "(#{vid_count}) Layabout" if vid_count > -1 # avoids updating to "(NaN) Layabout" on /about or / pre-login
  vids_per = 10 # adjust to taste
  vids_showing = load_more_vids(0, vids_per, vid_count, 0) # params: currently showing, how many to load, total in queue, speed
  moving = false # not currently moving a bookmark to another folder
  current_folder = $("#videos").attr "folder_id"
  underline_current_folder(current_folder)

  $(".header").on "click", ".folder_link", (event) -> # when clicking on a folder link in the header
    if $(this).hasClass "glowing"
      event.preventDefault() # won't follow the link
      id_to_move = moving
      moving = false
      folder_id_clicked = $(this).attr "id"
      folder_title = $(this).text()
      remove_video(id_to_move)
      vid_count--
      vids_showing--
      update_count(vid_count)
      $(".folder_link").removeClass "glowing animated swing"
      vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
      $("<div/>").load "/move/#{id_to_move}/to/#{folder_id_clicked}", ->
        puts $(this).text()


  $("#yield").on "click", "button", -> # ALL button presses. is this wise?


    action = $(this).text() # reads the text of the button
    id = $(this).closest(".video").attr "id"


    if action is "More Videos"
      vids_showing = load_more_vids(vids_showing, vids_per, vid_count, 'slow')


    else if action is "Watch"
      $(this).text "Loading..."
      shower = $(this)
      vid_home = $(this).siblings(".vid_embed")
      video_url = $(this).siblings('h3').find('a').attr('href')
      vid_home.load "/embedcode?url=#{ video_url  }", ->
        $(window).resize() # to toggle the video resize
        vid_home.slideToggle 'fast'
        shower.remove()



    else if action is "Like"
      $(this).text "Unlike"
      $(this).siblings(".both").text "Unlike and Delete"
      $(this).siblings(".delete").attr "disabled", "disabled"
      $('<div/>').load "/like/#{id}", ->
        puts $(this).text()


    else if action is "Unlike"
      $(this).text "Like"
      $(this).siblings(".both").text "Like and Archive"
      $(this).siblings(".delete").removeAttr "disabled"
      $("<div/>").load "/unlike/#{id}", ->
        puts $(this).text()


    else if action is "Like and Archive"
      if confirm "You sure?"
        remove_video(id)
        vid_count--
        vids_showing--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $('<div/>').load "/like-and-archive/#{id}", ->
          puts $(this).text()


    else if action is "Archive"
      if confirm "You sure?"
        remove_video(id)
        vid_count--
        vids_showing--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/archive/#{id}", ->
          puts $(this).text()


    else if action is "Delete"
      if confirm "You sure?"
        remove_video(id)
        vid_count--
        vids_showing--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/delete/#{id}", ->
          puts $(this).text()


    else if action is "Move"
      $(".folder_link").not("##{current_folder}")
        .toggleClass("animated swing glowing")
      moving = if moving then false else id # cancel or start a move


    else if action is "Unlike and Delete"
      if confirm "You sure?"
        remove_video(id)
        vid_count--
        vids_showing--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/unlike-and-delete/#{id}", ->
          puts $(this).text()

# show or hide the ajax spinner gif, when requests are being made
$(document).ajaxStart ->
  $('#ajax_gif').css "display", "inline"
$(document).ajaxStop ->
  $('#ajax_gif').css "display", "none"

