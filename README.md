[![Build Status](https://travis-ci.org/jusroberts/pingpong-web-server.svg?branch=master)](https://travis-ci.org/jusroberts/pingpong-web-server)
[![Code Climate](https://codeclimate.com/github/jusroberts/pingpong-web-server/badges/gpa.svg)](https://codeclimate.com/github/jusroberts/pingpong-web-server)

## Quickstart for developing on this repo

### Getting your environment set up

1. Ensure that you have the following installed:
  * Ruby 2.6.x 
  * The `bundler` gem
  * Postgresql (as it's necessary for the `pg` gem used by this project)
2. Run `bundle install`
3. Run `./bin/rake db:setup`

### Running the app

`./bin/rails server` does the trick, as this is a Rails app.