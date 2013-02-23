// Generated by CoffeeScript 1.4.0
(function() {
  var load_more_vids, underline_current_folder, update_count;

  update_count = function(num) {
    $("#vid_count").text(num);
    if (num === 0) {
      return $("#videos").load("<p>No more videos!</p>");
    }
  };

  underline_current_folder = function(id) {
    $("#" + id).css("text-decoration", "underline");
    return $(".folder_link").not("#" + id).css("text-decoration", "none");
  };

  load_more_vids = function(vids_showing, vids_per, vid_count, speed) {
    if (vid_count - vids_showing > vids_per) {
      $(".video").slice(vids_showing, vids_showing + vids_per).slideToggle(speed);
      vids_showing += vids_per;
    } else {
      $(".video").slice(vids_showing, vid_count).slideToggle(speed);
      vids_showing = vid_count;
      $("#more_videos").slideToggle('fast');
    }
    console.log("Showing " + vids_showing + " of " + vid_count + " videos");
    return vids_showing;
  };

  $(document).ajaxStart(function() {
    return $('#ajax_gif').css("display", "inline");
  });

  $(document).ajaxStop(function() {
    return $('#ajax_gif').css("display", "none");
  });

  $(document).ready(function() {
    var current_folder, height_diff, moving, to_move, vid_count, vids_per, vids_showing;
    height_diff = $(document).height() - $("body").height();
    if (height_diff > 0) {
      $("#buffer2").css("height", "" + (height_diff - 50) + "px");
    }
    vid_count = parseInt($("#vid_count").text());
    vids_per = 5;
    vids_showing = 0;
    vids_showing = load_more_vids(vids_showing, vids_per, vid_count, 0);
    moving = false;
    to_move = "";
    current_folder = $("#folder_id").text();
    underline_current_folder(current_folder);
    $(".folder_link").click(function() {
      var folder_id_clicked, path, title, title_coaxed;
      folder_id_clicked = this.id;
      title = this.innerHTML;
      title_coaxed = title.replace(/\s/, '-');
      if (moving === true && to_move !== "") {
        if ($(this).hasClass("glowing")) {
          console.log("Trying to move " + to_move + " to " + title);
          $(".video#" + to_move).toggle('fast');
          moving = false;
          vid_count--;
          update_count(vid_count);
          $(".folder_link").removeClass("glowing");
          vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
          $("<div/>").load("/move/" + to_move + "/to/" + folder_id_clicked, function() {
            return console.log("Successfully moved link to " + title);
          });
          return to_move = "";
        }
      } else {
        path = '/';
        if (title !== "Read Later") {
          path = "/folder/" + folder_id_clicked + "/" + title_coaxed;
        }
        return $("#yield").load("" + path + " #yield", function() {
          history.pushState({}, "Loading " + title, path);
          current_folder = $("#folder_id").text();
          underline_current_folder(current_folder);
          $("#buffer2").css("height", "0");
          height_diff = $(document).height() - $("body").height();
          if (height_diff > 0) {
            $("#buffer2").css("height", "" + (height_diff - 50) + "px");
          }
          vid_count = parseInt($("#vid_count").text());
          vids_showing = 0;
          return vids_showing = load_more_vids(vids_showing, vids_per, vid_count, 0);
        });
      }
    });
    return $("#yield").on("click", "button", function() {
      var action, id, shower, vid_site, video_id;
      action = $(this).text();
      id = this.id;
      if (action === "More Videos") {
        return vids_showing = load_more_vids(vids_showing, vids_per, vid_count, 'slow');
      } else if (action === "Show video") {
        shower = $(this);
        vid_site = $(this).siblings(".vid_site").text();
        video_id = $(this).siblings(".video_id").text();
        return shower.siblings(".vid_embed").load("/embedcode/" + vid_site + "/" + video_id, function() {
          return shower.remove();
        });
      } else if (action === "Like") {
        $(this).closest(".buttonsets").children().toggle('fast');
        return $('<div/>').load("/like/" + id, function() {
          return console.log("Successfully liked " + id);
        });
      } else if (action === "Like and Archive") {
        if (confirm("You sure?")) {
          $(".video#" + id).slideToggle('fast');
          vid_count--;
          update_count(vid_count);
          vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
          return $('<div/>').load("/like-and-archive/" + id, function() {
            return console.log("Successfully liked-and-archived " + id);
          });
        }
      } else if (action === "Archive") {
        if (confirm("You sure?")) {
          $(".video#" + id).slideToggle('fast');
          vid_count--;
          update_count(vid_count);
          vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
          return $("<div/>").load("/archive/" + id, function() {
            return console.log("Successfully archived " + id);
          });
        }
      } else if (action === "Delete") {
        if (confirm("You sure?")) {
          $(".video#" + id).slideToggle('fast');
          vid_count--;
          update_count(vid_count);
          vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
          return $("<div/>").load("/delete/" + id, function() {
            return console.log("Successfully deleted " + id);
          });
        }
      } else if (action === "Move") {
        $(".folder_link").not("#" + current_folder).toggleClass("glowing");
        $(".folder_link").not("#" + current_folder).ClassyWiggle('start');
        if (moving === true) {
          moving = false;
          return to_move = "";
        } else {
          moving = true;
          return to_move = id;
        }
      } else if (action === "Unlike") {
        $(this).closest(".buttonsets").children().toggle('fast');
        return $("<div>").load("/unlike/" + id, function() {
          return console.log("Successfully unliked " + id);
        });
      } else if (action === "Unlike and Delete") {
        if (confirm("You sure?")) {
          return $(this).closest(".buttonsets").children().toggle(750, function() {
            $(".video#" + id).slideToggle('fast');
            vid_count--;
            update_count(vid_count);
            vids_showing = load_more_vids(vids_showing, 1, vid_count, 'slow');
            return $("<div/>").load("/unlike-and-delete/" + id, function() {
              return console.log("Successfully unliked-and-deleted " + id);
            });
          });
        }
      }
    });
  });

}).call(this);
