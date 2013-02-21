
update_count = (num) ->
  $("#vid_count").text(num)
  $("#videos").load("<p>No more videos!</p>") if num is 0
  # also, update the title eventually

underline_current_folder = (id) ->
  $("##{id}").css "text-decoration", "underline"
  $(".folder_link").not("##{id}").css "text-decoration", "none"

load_more_vids = (vids_showing, vids_per, vid_count) ->
  #  does this play well with dom removed vids?
  # are they removed or just hidden? that matters, right?
  # console.log "From #{start} to #{stop}"
  if vid_count - vids_showing > vids_per
    $(".video").slice(vids_showing, vids_showing + vids_per).slideToggle 'slow'
    vids_showing += vids_per
  else
    $(".video").slice(vids_showing, vid_count).slideToggle 'slow'
    vids_showing = vid_count
    $("#more_videos").slideToggle 'fast'
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
  vids_showing = load_more_vids(vids_showing, vids_per, vid_count)
  moving = false
  to_move = ""
  current_folder = $("#folder_id").text()
  underline_current_folder(current_folder)

  $(".folder_link").click ->
    folder_id_clicked = this.id
    title = this.innerHTML
    title_coaxed = title.replace(/\s/, '-') # whitespace to hyphens
    if moving is true and to_move isnt ""
      if $(this).hasClass "glowing"
        console.log "Trying to move #{to_move} to #{title}"
        $(".video##{to_move}").toggle 'fast'
        moving = false
        vid_count--
        update_count(vid_count)
        $(".folder_link").removeClass "glowing"
        $("<div/>").load "/move/#{to_move}/to/#{folder_id_clicked}", ->
          console.log "Successfully moved link to #{title}"
        to_move = ""
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
        vids_showing = load_more_vids(vids_showing, vids_per, vid_count)

  $("#yield").on "click", "button", ->
    action = $(this).text() # reads the text of the button
    id = this.id
    if action is "More Videos"
      vids_showing = load_more_vids(vids_showing, vids_per, vid_count)
    else if action is "Like"
      $(this).closest(".buttonsets").children().toggle 'fast'
      $('<div/>').load "/like/#{id}", ->
        # "success is incorrect, sometimes it just times out"
        # TODO catch and interpet error messages
        console.log "Successfully liked #{id}"
    else if action is "Like and Archive"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast'
        vid_count--
        update_count(vid_count)
        $('<div/>').load "/like-and-archive/#{id}", ->
          console.log "Successfully liked-and-archived #{id}"
    else if action is "Archive"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast'
        vid_count--
        update_count(vid_count)
        $("<div/>").load "/archive/#{id}", ->
          console.log "Successfully archived #{id}"
    else if action is "Delete"
      if confirm "You sure?"
        $(".video##{id}").slideToggle 'fast'
        vid_count--
        update_count(vid_count)
        $("<div/>").load "/delete/#{id}", ->
          console.log "Successfully deleted #{id}"
    else if action is "Move"
      $(".folder_link").not("##{current_folder}").toggleClass "glowing"
      if moving is true
        moving = false
        to_move = ""
      else
        moving = true
        to_move = id
    else if action is "Unlike"
      $(this).closest(".buttonsets").children().toggle 'fast'
      $("<div>").load "/unlike/#{id}", ->
        console.log "Successfully unliked #{id}"
    else if action is "Unlike and Delete"
      if confirm "You sure?"
        $(this).closest(".buttonsets").children().toggle 750, ->
          $(".video##{id}").slideToggle 'fast'
          vid_count--
          update_count(vid_count)
          $("<div/>").load "/unlike-and-delete/#{id}", ->
            console.log "Successfully unliked-and-deleted #{id}"
















