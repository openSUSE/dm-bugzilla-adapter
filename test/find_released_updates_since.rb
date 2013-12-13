#!/usr/bin/env ruby
#
# find_released_updates_since.rb
#
# Script to find released updates for SUSE Manager
#
# Uses dm-bugzilla-adapter to query bugzilla.novell.com
#
require 'rubygems'
require 'helper'
require 'dm-core'
require 'dm-bugzilla-adapter'

DataMapper::Logger.new(STDOUT, :debug)
keeper = DataMapper.setup(:default,
			  :adapter => 'bugzilla',
			  :url  => 'https://bugzilla.novell.com')

require 'bugzilla/bug'
DataMapper.finalize

bugs = Bug.all(:product.like => "SUSE Manager", :resolution => "FIXED", :whiteboard.like => "released")

bugs.each do |bug|
  puts "%s: %s" % [bug.id, bug.summary]
end
