#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require turbolinks
#= require_tree .
#= require_self

$(document).on 'ready page:load', ->
  $('.video .title').on 'click', ->
    $.get '/embed',
      url: $(this).data('url')
      bookmark_id: $(this).closest('.video').attr('id')

      
      # hello
