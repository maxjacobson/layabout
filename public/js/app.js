require(['jquery', 'alertify.min', 'bootstrap.min'], function ($, alertify) {

  $(document).ajaxStart(function() {
    $('#ajax_gif').css("display", "inline");
  });

  $(document).ajaxStop(function() {
    $('#ajax_gif').css("display", "none");
  });

  $(document).ready(function () {
    var current_page = 1;
    var last_page_load = new Date();
    var made_it_to_end = false;


    function buttons_for_liked_video(id) {
      return '<p class="button-group">\n  <button class="btn btn-success unlike-button" id="' + id + '">Unlike <i class="icon-heart icon-white"></i></button>\n<button class="btn btn-warning archive-button" id="' + id + '">Archive <i class="icon-folder-open icon-white"></i></button>\n  <button class="btn btn-danger disabled flacid-delete-button">Delete <i class="icon-remove icon-white"></i></button>\n  <button class="btn btn-danger unlike-and-delete-button" id="' + id + '">Unlike and Delete <i class="icon-remove icon-white"></i></button>\n</p>'
    }
    function buttons_for_unliked_video(id) {
      return '<p class="button-group">\n  <button class="btn btn-primary like-button" id="' + id + '">Like <i class="icon-heart icon-white"></i></button>\n    <button class="btn btn-primary like-and-archive-button" id="' + id + '">Like and archive <i class="icon-heart icon-white"></i> <i class="icon-folder-open icon-white"></i></button>\n  <button class="btn btn-warning archive-button" id="' + id + '">Archive <i class="icon-folder-open icon-white"></i></button>\n  <button class="btn btn-danger delete-button" id="' + id + '">Delete <i class="icon-remove icon-white"></i></button>\n</p>'
    }
    function get_new_title() {
      $('<div/>').load('/num_of_videos', function() {
        var num = this.innerHTML;
        // alertify.log("there are this many videos: " + num);
        document.title = '(' + num + ') Layabout'
      });
    }

    $('<div/>').load('/page/1' + ' #just_videos', function() {
      $(this).appendTo('#just_videos');
      get_new_title();
    });


    $(".like-button").live("click", function() {
      var id = this.id;
      $('<div/>').load('/like/' + id);
      $(this).parent().replaceWith(buttons_for_liked_video(id));
      alertify.log('Liked');
    });
    $(".like-and-archive-button").live("click", function() {
      var id = this.id;
      $('<div/>').load('/like-and-archive/' + id);
      $('div#' + id).remove();
      alertify.log('Liked and Archived');
    });
    $(".unlike-button").live("click", function() {
      var id = this.id;
      $('<div/>').load('/unlike/' + id);
      $(this).parent().replaceWith(buttons_for_unliked_video(id));
      alertify.log('Unliked');
    });
    $(".unlike-and-delete-button").live("click", function() {
      var id = this.id;
      alertify.confirm("You sure?", function (yep) {
        if (yep) {
          $('<div/>').load('/unlike-and-delete/' + id);
          $('div#' + id).remove();
          get_new_title();
          alertify.log("Unliked and Deleted");
        } else {
          alertify.log('Canceled');
        }
      });
    });
    $(".archive-button").live("click", function() {
      document.title = '() Layabout';
      var id = this.id;
      $('<div/>').load('/archive/' + id);
      $('div#' + id).remove();
      alertify.log('Archived');
      get_new_title();
    });
    $(".delete-button").live("click", function() {
      var id = this.id;
      alertify.confirm("You sure?", function (yep) {
        if (yep) {
          $('<div/>').load('/delete/' + id);
          alertify.log('Deleted');
          $('div#' + id).remove();
          get_new_title();
        } else {
          alertify.log('Canceled');
        }
      });
    });
    $(".flaccid-delete-button").on("click", function(event) {
      alertify.log("Can't delete something you like");
    });

    $(window).scroll(function() {
      if($(window).scrollTop() + $(window).height() == $(document).height()) {
        $('<div/>').load('/num_of_pages', function() {
          var num = parseInt(this.innerHTML);
          if (current_page < num) {
            var now = new Date();
            if (now - last_page_load > 2000) { // trying to make a little buffer btwn loading pages. this value is in milliseconds (i think)
              current_page++;
              // alertify.log("Loading page " + current_page + "...");
              $('<div/>').load('/page/' + current_page + ' #just_videos', function() {
                $(this).appendTo('#just_videos');
              });
              last_page_load = new Date();
            } else {
              alertify.log("Please wait a moment");
            }
          } else {
            if (made_it_to_end == false) {
              alertify.log("No more videos");
              made_it_to_end = true;
            }
          }
        });
      }
    });
  });
});
