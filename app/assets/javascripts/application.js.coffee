#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require turbolinks
#= require_tree .
#= require_self

$(document).on 'ready page:load', ->
  $('.video .title').one 'click', ->
    $.get '/embed',
      url: $(this).data('url')
      bookmark_id: $(this).closest('.video').attr('id')
    ,
    (video) =>
      console.log video
      if video.watchable
        $(video.html).insertAfter $(this)
        $(document).trigger 'newVideoAdded'
      else if video.readable
        $(video.html).insertAfter $(this)
      else
        $("<p />").text(video.reason).insertAfter $(this)
