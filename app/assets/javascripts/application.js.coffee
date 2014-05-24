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
      (data) =>
        if data.watchable
          $(data.html).insertAfter $(this)
          $(document).trigger 'newVideoAdded'
        else
          console.log data.reason


