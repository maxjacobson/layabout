# Layabout

[![Build Status](https://travis-ci.org/maxjacobson/layabout.svg)](https://travis-ci.org/maxjacobson/layabout)
[![Code Climate](https://codeclimate.com/github/maxjacobson/layabout/badges/gpa.svg)](https://codeclimate.com/github/maxjacobson/layabout)
[![Test Coverage](https://codeclimate.com/github/maxjacobson/layabout/badges/coverage.svg)](https://codeclimate.com/github/maxjacobson/layabout)

## What it is

1. A site for Instapaper subscribers to go to and watch all the videos they've
saved. Just kick back and enjoy.
2. A command line interface 

## setup

* `git clone git@github.com:maxjacobson/layabout.git`
* `cd layabout`
* `bundle install`
* `cp config/instapaper.yml.example config/instapaper.yml`
* edit `config/instapaper.yml` with your Instapaper API credentials
* `bin/rake db:setup` to setup the database
* `bin/rails s` for the web interface
* `bin/rake explore` for the command-line interface (must first run the web app and sign in there)

## deploying to Heroku

* `heroku config:set SKYLIGHT_AUTHENTICATION="<token>"`

## LICENSE

The MIT License (MIT)

Copyright (c) 2014 Max Jacobson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

