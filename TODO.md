# TODOS

* make this a full Instapaper client?
* like, show *all links* and then if it's a video, include the video
* if it's an instagram, show the gram
* etc
* TODO get rid of oembed it's slow and buggy
* learn to use jquery .load and implement infinite scroll

    http://www.infinite-scroll.com
    // load all post divs from page 2 into an off-DOM div
    $('<div/>').load('/page/2/ #content div.post',function(){ 
        $(this).appendTo('#content');    // once they're loaded, append them to our content area
    });

* related: can I use this load function to implement ajaxy button press actions? can we load `/delete/1234` and then use jquery to hide or remove that video? I think...? test it
* related: is that potentially also a solution to the Big Bug? maybe I can do like `loadcode/vimeo/1234` that returns a string...? maybe not