###
  Note to anyone who may be viewing the JavaScript of this web page:
  This was written in CoffeeScript and so some stuff may look weird in the compiled version.
  I don't understand why 'return' is in there so much. I never did that when I was writing JavaScript.
  I'd like to figure out source maps so this can point to the CS file, but I have to go eat I'm so hungry.
###

$(document).ready ->
  height_diff = $(document).height() - $("body").height()
  $("#buffer2").css "height", "#{height_diff - 50}px" if height_diff > 0
  vid_count = parseInt($("#vid_count").text()) # provided by the videos.haml file
  document.title = "(#{vid_count}) Layabout" if vid_count > -1
  vids_per = 10 # adjust to taste
  vids_showing = load_more_vids(0, vids_per, vid_count, 0)
      # above params: currently showing, how many to load, total in queue, speed
  moving = false # not currently moving a bookmark to another folder
  current_folder = $("#videos").attr "folder_id"
  underline_current_folder(current_folder)
  if (navigator.userAgent.match(/iPod|iPhone|iPad/))
    $(".hulu").remove() # no flash!


  $(".folder_link").click (event) ->
    if moving isnt false
      event.preventDefault() # won't follow the link
      if $(this).hasClass "glowing" # doesn't include current pagefolder
        id_to_move = moving
        moving = false
        folder_id_clicked = $(this).attr "id"
        folder_title = $(this).text()
        $(".video##{id_to_move}").slideToggle 'fast', ->
          $(this).remove()
        vid_count--
        vids_showing--
        update_count(vid_count)
        $(".folder_link").removeClass "animated swing hinge glowing"
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/move/#{id_to_move}/to/#{folder_id_clicked}", ->
          console.log "Successfully moved #{id_to_move} to #{folder_title}"


  $("#yield").on "click", "button", -> # ALL button presses. is this wise?


    action = $(this).text() # reads the text of the button
    id = $(this).closest(".video").attr "id"


    if action is "More Videos"
      vids_showing = load_more_vids(vids_showing, vids_per, vid_count, 'slow')


    else if action is "Load video"
      shower = $(this)
      video_id = $(this).attr "video_id"
      vid_site =  $(this).attr "vid_site"
      vid_home = $(this).siblings(".vid_embed")
      vid_home.load "/embedcode/#{vid_site}/#{video_id}", ->
        vid_home.slideToggle 'fast'
        shower.remove()


    else if action is "Like"
      $(this).text "Unlike"
      $(this).siblings(".both").text "Unlike and Delete"
      $(this).siblings(".delete").attr "disabled", "disabled"
      $('<div/>').load "/like/#{id}", ->
        # "success" is incorrect, sometimes it just times out
        # TODO catch and interpet error messages
        console.log "Successfully liked #{id}"


    else if action is "Like and Archive"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast', ->
          $(".video##{id}").remove()
        vid_count--
        vids_showing--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $('<div/>').load "/like-and-archive/#{id}", ->
          console.log "Successfully liked-and-archived #{id}"


    else if action is "Archive"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast', ->
          $(".video##{id}").remove()
        vid_count--
        vids_showing--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/archive/#{id}", ->
          console.log "Successfully archived #{id}"


    else if action is "Delete"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast', ->
          $(".video##{id}").remove()
        vid_count--
        vids_showing--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/delete/#{id}", ->
          console.log "Successfully deleted #{id}"


    else if action is "Move"
      $(".folder_link").not("##{current_folder}").toggleClass "animated swing hinge glowing"
      moving = if moving then false else id # cancel or start a move


    else if action is "Unlike"
      $(this).text "Like"
      $(this).siblings(".both").text "Like and Archive"
      $(this).siblings(".delete").removeAttr "disabled"
      $("<div>").load "/unlike/#{id}", ->
        console.log "Successfully unliked #{id}"


    else if action is "Unlike and Delete"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast', ->
          $(".video##{id}").remove()
        vid_count--
        vids_showing--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/unlike-and-delete/#{id}", ->
          console.log "Successfully unliked-and-deleted #{id}"

update_count = (num) ->
  document.title = "(#{num}) Layabout"
  $("#vid_count").text(num)
  if num is 0
    $("#yield").append("<p>No more videos!</p>")
    $("#more_videos").slideToggle 'fast' # gets rid of button


underline_current_folder = (id) ->
  $("##{id}").css "text-decoration", "underline"
  $(".folder_link").not("##{id}").css "text-decoration", "none"


load_more_vids = (vids_showing, vids_per, vid_count, speed) ->
  #  does this play well with dom removed vids?
  # are they removed or just hidden? that matters, right?
  # should we use a different name for "vids_per" in this context?
  queue = $(".video.hiding")
  if vid_count - vids_showing > vids_per
    queue.slice(0, vids_per).slideToggle speed, ->
      $(this).removeClass 'hiding'
    console.log "Showing #{vids_showing + vids_per} of #{vid_count} videos"
    return vids_showing + vids_per # new total of visible videos
  else
    queue.slideToggle speed, ->
      $(this).removeClass 'hiding'
    console.log "Showing all #{vid_count} videos"
    return vid_count # new total of visible videos


$(document).ajaxStart ->
  $('#ajax_gif').css "display", "inline"
$(document).ajaxStop ->
  $('#ajax_gif').css "display", "none"











