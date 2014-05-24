#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require_tree .
#= require_self

$(document).on 'ready page:load', ->
  $('.video .title').one 'click', ->
    $.get '/embed',
      url: $(this).data('url')
    ,
    (video) =>
      if video.watchable
        $(video.html).insertAfter $(this)
        $(document).trigger 'newVideoAdded'
      else
        $("<p />").text(video.reason).insertAfter $(this)
