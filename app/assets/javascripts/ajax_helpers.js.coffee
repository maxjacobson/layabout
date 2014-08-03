# show or hide the ajax spinner gif, when requests are being made
$(document).on 'ajaxStart page:fetch', ->
  $('#ajax_gif').css "display", "inline"
$(document).on 'ajaxStop page:load', ->
  $('#ajax_gif').css "display", "none"
