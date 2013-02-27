# TODOS

* use the bootstrap buttons, or some other kind. or just learn from them...
# "success" is incorrect, sometimes it just times out
        # TODO catch and interpet error messages
* if you click move on one video, and then move on another video, what happens and what are your expectations?
* improve the responsive design, it's screwy. it's *so* screwy. what happened to mobile first?
* consider how the design can flex based on how many folders there are -- what if someone has twenty?
* do a total google-reader style keyboard shortcut system?
* use ajax for the `/add` button (re-implement it)
* make this a full Instapaper client?
    * like, show *all links* and then if it's a video, include the video
    * if it's an instagram, show the gram

* * *

Instead of clicking `move` toggling the "glowing" class on the folder links, it should instead do like `addAttr "to_move_id", 1234`. that way, if you click "move" on one video, and then "move" on another video, it won't *cancel* the move, it'll simply begin the move process anew with a different ID.