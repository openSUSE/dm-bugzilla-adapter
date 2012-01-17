#
# dm-bugzilla-adapter.rb
#
# A DataMapper adapter for Bugzilla
#
#--
# Copyright (c) 2011 SUSE LINUX Products GmbH
#
# Author: Klaus Kämpf <kkaempf@suse.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'rubygems'

# DataMapper
require 'dm-core'
require 'dm-core/adapters/abstract_adapter'

# bugzilla xmlrpc
require "bicho"

# bugzilla https
require 'net/https'
require 'nokogiri'

# dm-bugzilla-adapter modules
require "dm-bugzilla-adapter/create"
require "dm-bugzilla-adapter/read"
require "dm-bugzilla-adapter/update"
require "dm-bugzilla-adapter/delete"
require "dm-bugzilla-adapter/misc"

module DataMapper
  class Property
    autoload :XML, "property/xml"
  end
end


module DataMapper::Adapters
  
  class BugzillaAdapter < AbstractAdapter

    # @api public
    def initialize(name, options)
      super
      require 'uri'
      @uri = URI.parse(options[:url])
      @client = Bicho::Client.new(@uri)
    end

    # get Bugs by ids
    def get_bugs(ids)
      @client.get_bugs(*ids)
    end
    
    # run named query, return Array of bug ids
    def named_query(name)
      @client.get_bugs(name)
    end
  end
end
