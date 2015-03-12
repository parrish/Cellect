# Cellect 
[![Build Status](https://travis-ci.org/zooniverse/Cellect.svg?branch=master)](https://travis-ci.org/zooniverse/Cellect)
[![Test Coverage](https://codeclimate.com/github/zooniverse/Cellect/badges/coverage.svg)](https://codeclimate.com/github/zooniverse/Cellect)
[![Gem Version](https://img.shields.io/gem/v/cellect.svg)](https://rubygems.org/gems/cellect)
[![Gem Version](https://img.shields.io/gem/v/cellect-client.svg)](https://rubygems.org/gems/cellect-client)
[![Gem Version](https://img.shields.io/gem/v/cellect-server.svg)](https://rubygems.org/gems/cellect-server)
[![Code Climate](https://codeclimate.com/github/zooniverse/Cellect/badges/gpa.svg)](https://codeclimate.com/github/zooniverse/Cellect)
<!-- [![Dependency Status](https://gemnasium.com/zooniverse/cellect.png)](https://gemnasium.com/zooniverse/cellect) -->

This is a work in progress

## Building

1. Install [Boost V1.55](http://www.boost.org/): OS X: `brew update && brew install boost`, Ubuntu: `sudo apt-get update && sudo apt-get install libboost-all-dev`
2. Install gem dependencies: `bundle` (See Note)


### Note
To install rice your Ruby must be compiled with shared libraries enabled, from the rice docs: 
* rvm:   `rvm reinstall [version] -- --enable-shared`
* rbenv: `CONFIGURE_OPTS="--enable-shared" rbenv install [version]`


## Testing

Run the specs with `rake`

## Start server:

`rackup # uses config.ru file` 

## Versions

See .travis.yml for supported ruby versions
