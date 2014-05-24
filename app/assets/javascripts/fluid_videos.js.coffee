# I want to use [this plugin](http://css-tricks.com/fluid-width-youtube-videos/)
# but it's in js, so I've adapted it to CoffeeScript and made it work with all iframes,
# not just youtube ones. dope plugin chris!

$(document).on 'ready page:load', ->

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
