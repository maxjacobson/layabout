# Layabout

## What it is

A site for Instapaper subscribers to go to and watch all the videos they've saved. Just kick back and enjoy.

## Running

from project route

* shotgun web.rb
* compass watch
    * for sass
* coffee -j public/js/app.js -cw assets/coffee/
    * for coffeescript
    * I made an alias 'americano' for this annoyingly complex command

## Notes

* 2012-11-03, got my Instapaper API credentials. Time to figure out how the fuck to use it.
* 2012-11-05, exploring rubygems.org and github for people who already did some of this work. probably going to use the gem `instapaper_full` which seems quite slick
* thought: offer some sorting options, so people can watch the shorter or longer ones depending on their mood. allow search.
* 2012-11-08, set it up as a sinatra app yesterday
* today did some URL and Title cleanup. OEmbed is finicky and will only accept clean URLs which is fine by me.
* added support for youtube short urls (`youtu.be/`) and mobile (`m.youtube.com`)
* 2012-11-09, separated the views into separate `.erb` files and it picked them up without a hitch. I'm mainly (well, completely) using erb because it's what Dan Benjamin was using in those videos I was watching, but some other resources I'm learning from use (and therefore implicitly recommend) either slim or haml. I think I'll stick with erb because it's basically just HTML with some ruby snuck in. I don't mind writing the brackets.
* I set up a `get` to allow *anything* to be typed in, and it'll just check if there's a view. and if not, it'll give a 404 error. I'm wondering if this is how I'll do certain actions... pass arguments in the URL
* nightime, I did implement that... now the buttons work but require a refresh for every action. I'm kind of just pleased that it works... it's kinda feature complete, just in a shitty, inefficient way.
* 2013-01-05, I have been udpating on the twitter more than here.
* 2013-02-19, deleted the whole thing and am starting over. Kind of. Will bring most of it back in. But I just want to be clean about it.
* 2013-02-20, I made a ton of progress. Implemented move-to-folder and re-implemented all of the other button actions. Still have to re-do infinite-scrolling and video embedding, but excited to re-think my approach :)