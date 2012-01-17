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
      bugs = @client.get_bugs(*ids)
    end
    
    # run named query, return Array of bug ids
    def named_query(name)
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      path = "/buglist.cgi?cmdtype=runnamed&namedcmd=#{name}&ctype=atom"
      limit = 10
      while limit > 0
        request = Net::HTTP::Get.new(path, { "Cookie" => @client.cookie } )
        response = http.request(request)
        case response
        when Net::HTTPSuccess
          bugs = []
          begin
            xml = Nokogiri::XML.parse(response.body)
            xml.root.xpath("//xmlns:entry/xmlns:link/@href", xml.root.namespace).each do |attr|
              uri = URI.parse attr.value
              bugs << uri.query.split("=")[1]
            end
          rescue Nokogiri::XML::XPath::SyntaxError
            raise "Named query '#{name}' not found"
          end
          limit = 0
          get_bugs(bugs)
        when Net::HTTPRedirection
          path = response['location']
          limit -= 1
        else
          limit = 0
          response.error!
        end
      end
    end
  end
end
