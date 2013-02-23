
update_count = (num) ->
  $("#vid_count").text(num)
  $("#videos").load("<p>No more videos!</p>") if num is 0
  # also, update the title eventually

underline_current_folder = (id) ->
  $("##{id}").css "text-decoration", "underline"
  $(".folder_link").not("##{id}").css "text-decoration", "none"

load_more_vids = (vids_showing, vids_per, vid_count, speed) ->
  #  does this play well with dom removed vids?
  # are they removed or just hidden? that matters, right?
  # should we use a different name for "vids_per" in this context?
  if vid_count - vids_showing > vids_per
    $(".video").slice(vids_showing, vids_showing + vids_per).slideToggle speed
    vids_showing += vids_per
  else
    $(".video").slice(vids_showing, vid_count).slideToggle speed
    vids_showing = vid_count
    $("#more_videos").slideToggle 'fast' # gets rid of the button
  console.log "Showing #{vids_showing} of #{vid_count} videos"
  return vids_showing

$(document).ajaxStart ->
  $('#ajax_gif').css "display", "inline"
$(document).ajaxStop ->
  $('#ajax_gif').css "display", "none"

$(document).ready ->
  height_diff = $(document).height() - $("body").height()
  $("#buffer2").css "height", "#{height_diff - 50}px" if height_diff > 0
  vid_count = parseInt($("#vid_count").text())
  vids_per = 5
  vids_showing = 0
  vids_showing = load_more_vids(vids_showing, vids_per, vid_count, 0)
  moving = false # not currently moving a bookmark to another folder
  current_folder = $("#folder_id").text()
  underline_current_folder(current_folder)

  $(".folder_link").click ->
    folder_id_clicked = this.id
    title = this.innerHTML
    title_coaxed = title.replace(/\s/, '-') # whitespace to hyphens
    if moving isnt false
      console.log "moving isnt false"
      if $(this).hasClass "animated" # bars moving to the same folder it's already in
        console.log "this has class animated"
        console.log "Trying to move #{moving} to #{title}"
        $(".video##{moving}").toggle 'fast', ->
          $(".video##{moving}").remove()
        vid_count--
        update_count(vid_count)
        $(".folder_link").removeClass "animated swing hinge glowing"
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/move/#{moving}/to/#{folder_id_clicked}", ->
          console.log "Successfully moved link to #{title}"
        moving = false
    else
      path = '/'
      path = "/folder/#{folder_id_clicked}/#{title_coaxed}" if title isnt "Read Later"
      $("#yield").load "#{path} #yield", ->
        history.pushState({}, "Loading #{title}", path)
        current_folder = $("#folder_id").text()
        underline_current_folder(current_folder)
        $("#buffer2").css "height", "0"
        height_diff = $(document).height() - $("body").height()
        $("#buffer2").css "height", "#{height_diff - 50}px" if height_diff > 0
        vid_count = parseInt($("#vid_count").text())
        vids_showing = 0
        vids_showing = load_more_vids(vids_showing, vids_per, vid_count, 0)

  $("#yield").on "click", "button", ->
    action = $(this).text() # reads the text of the button
    id = this.id
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
      $(this).closest(".buttonsets").children().toggle 'fast'
      $('<div/>').load "/like/#{id}", ->
        # "success is incorrect, sometimes it just times out"
        # TODO catch and interpet error messages
        console.log "Successfully liked #{id}"
    else if action is "Like and Archive"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast', ->
          $(".video##{id}").remove()
        vid_count--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $('<div/>').load "/like-and-archive/#{id}", ->
          console.log "Successfully liked-and-archived #{id}"
    else if action is "Archive"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast', ->
          $(".video##{id}").remove()
        vid_count--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/archive/#{id}", ->
          console.log "Successfully archived #{id}"
    else if action is "Delete"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast', ->
          $(".video##{id}").remove()
        vid_count--
        update_count(vid_count)
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
        $("<div/>").load "/delete/#{id}", ->
          console.log "Successfully deleted #{id}"
    else if action is "Move"
      $(".folder_link").not("##{current_folder}").toggleClass "animated swing glowing"
      if moving isnt false
        moving = false
      else
        moving = id
    else if action is "Unlike"
      $(this).closest(".buttonsets").children().toggle 'fast'
      $("<div>").load "/unlike/#{id}", ->
        console.log "Successfully unliked #{id}"
    else if action is "Unlike and Delete"
      if confirm "You sure?"
        $(this).closest(".buttonsets").children().toggle 750, ->
          $(".video##{id}").slideToggle 'fast', ->
            $(".video##{id}").remove()
          vid_count--
          update_count(vid_count)
          vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow')
          $("<div/>").load "/unlike-and-delete/#{id}", ->
            console.log "Successfully unliked-and-deleted #{id}"
















