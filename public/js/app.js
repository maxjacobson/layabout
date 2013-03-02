// Generated by CoffeeScript 1.4.0

/*
  Note to anyone who may be viewing the JavaScript of this web page:
  This was written in CoffeeScript and so some stuff may look weird in the compiled version.
  I don't understand why 'return' is in there so much. I never did that when I was writing JavaScript.
  I'd like to figure out source maps so this can point to the CS file, but I have to go eat I'm so hungry.
*/


(function() {
  var delay, load_more_vids, remove_video, underline_current_folder, update_count;

  $(document).ready(function() {
    var current_folder, height_diff, moving, vid_count, vids_per, vids_showing;
    height_diff = $(document).height() - $("body").height();
    if (height_diff > 0) {
      $("#buffer2").css("height", "" + (height_diff - 50) + "px");
    }
    vid_count = parseInt($("#vid_count").text());
    if (vid_count > -1) {
      document.title = "(" + vid_count + ") Layabout";
    }
    vids_per = 10;
    vids_showing = load_more_vids(0, vids_per, vid_count, 0);
    moving = false;
    current_folder = $("#videos").attr("folder_id");
    underline_current_folder(current_folder);
    if (navigator.userAgent.match(/iPod|iPhone|iPad/)) {
      $(".hulu").remove();
    }
    $(".header").on("click", ".folder_link", function(event) {
      var folder_id_clicked, folder_title, id_to_move;
      if ($(this).hasClass("glowing")) {
        event.preventDefault();
        id_to_move = moving;
        moving = false;
        folder_id_clicked = $(this).attr("id");
        folder_title = $(this).text();
        remove_video(id_to_move);
        vid_count--;
        vids_showing--;
        update_count(vid_count);
        $(".folder_link").removeClass("glowing animated swing");
        vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
        return $("<div/>").load("/move/" + id_to_move + "/to/" + folder_id_clicked, function() {
          return console.log($(this).text());
        });
      }
    });
    return $("#yield").on("click", "button", function() {
      var action, id, shower, vid_home, vid_site, video_id;
      action = $(this).text();
      id = $(this).closest(".video").attr("id");
      if (action === "More Videos") {
        return vids_showing = load_more_vids(vids_showing, vids_per, vid_count, 'slow');
      } else if (action === "Watch") {
        $(this).text("Loading...");
        shower = $(this);
        video_id = $(this).attr("video_id");
        vid_site = $(this).attr("vid_site");
        vid_home = $(this).siblings(".vid_embed");
        return vid_home.load("/embedcode/" + vid_site + "/" + video_id, function() {
          vid_home.slideToggle('fast');
          return shower.remove();
        });
      } else if (action === "Like") {
        $(this).text("Unlike");
        $(this).siblings(".both").text("Unlike and Delete");
        $(this).siblings(".delete").attr("disabled", "disabled");
        return $('<div/>').load("/like/" + id, function() {
          return console.log($(this).text());
        });
      } else if (action === "Unlike") {
        $(this).text("Like");
        $(this).siblings(".both").text("Like and Archive");
        $(this).siblings(".delete").removeAttr("disabled");
        return $("<div/>").load("/unlike/" + id, function() {
          return console.log($(this).text());
        });
      } else if (action === "Like and Archive") {
        if (confirm("You sure?")) {
          remove_video(id);
          vid_count--;
          vids_showing--;
          update_count(vid_count);
          vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
          return $('<div/>').load("/like-and-archive/" + id, function() {
            return console.log($(this).text());
          });
        }
      } else if (action === "Archive") {
        if (confirm("You sure?")) {
          remove_video(id);
          vid_count--;
          vids_showing--;
          update_count(vid_count);
          vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
          return $("<div/>").load("/archive/" + id, function() {
            return console.log($(this).text());
          });
        }
      } else if (action === "Delete") {
        if (confirm("You sure?")) {
          remove_video(id);
          vid_count--;
          vids_showing--;
          update_count(vid_count);
          vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
          return $("<div/>").load("/delete/" + id, function() {
            return console.log($(this).text());
          });
        }
      } else if (action === "Move") {
        $(".folder_link").not("#" + current_folder).toggleClass("animated swing glowing");
        return moving = moving ? false : id;
      } else if (action === "Unlike and Delete") {
        if (confirm("You sure?")) {
          remove_video(id);
          vid_count--;
          vids_showing--;
          update_count(vid_count);
          vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
          return $("<div/>").load("/unlike-and-delete/" + id, function() {
            return console.log($(this).text());
          });
        }
      }
    });
  });

  update_count = function(num) {
    document.title = "(" + num + ") Layabout";
    $("#vid_count").text(num);
    if (num === 0) {
      $("#messages").text("No more videos!");
      return $("#more_videos").remove();
    }
  };

  underline_current_folder = function(id) {
    return $("#" + id).css("text-decoration", "underline");
  };

  load_more_vids = function(vids_showing, num_to_load, vid_count, speed) {
    var queue;
    queue = $(".video.hiding");
    if (vid_count - vids_showing > num_to_load) {
      queue.slice(0, num_to_load).slideToggle(speed, function() {
        return $(this).removeClass('hiding');
      });
      console.log("Showing " + (vids_showing + num_to_load) + " of " + vid_count + " videos");
      return vids_showing + num_to_load;
    } else {
      if ($("#messages").text() === "") {
        $("#messages").text("You've reached the bottom of this folder!");
      }
      $("#more_videos").slideToggle('fast');
      queue.slideToggle(speed, function() {
        return $(this).removeClass('hiding');
      });
      console.log("Showing all " + vid_count + " videos");
      return vid_count;
    }
  };

  delay = function(s, func) {
    return setTimeout(func, s * 1000);
  };

  remove_video = function(video_id) {
    var video;
    video = $(".video#" + video_id);
    if (Math.random() > 0.5) {
      video.addClass("animated bounceOutLeft");
    } else {
      video.addClass("animated bounceOutRight");
    }
    return delay(1, function() {
      return video.remove();
    });
  };

  $(document).ajaxStart(function() {
    return $('#ajax_gif').css("display", "inline");
  });

  $(document).ajaxStop(function() {
    return $('#ajax_gif').css("display", "none");
  });

}).call(this);
