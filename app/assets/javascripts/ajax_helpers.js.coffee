# show or hide the ajax spinner gif, when requests are being made
$(document).ajaxStart ->
  $('#ajax_gif').css "display", "inline"
$(document).ajaxStop ->
  $('#ajax_gif').css "display", "none"
