#
# dm-bugzilla-adapter.rb
#
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
      request = Net::HTTP::Get.new("/buglist.cgi?cmdtype=runnamed&namedcmd=#{name}&ctype=atom", { "Cookie" => @client.cookie } )
      response = http.request(request)
      case response
      when Net::HTTPSuccess
	bugs = []
	xml = Nokogiri::XML.parse(response.body)
	xml.root.xpath("//xmlns:entry/xmlns:link/@href", xml.root.namespace).each do |attr|
	  uri = URI.parse attr.value
	  bugs << uri.query.split("=")[1]
	end
	get_bugs(bugs)
      when Net::HTTPRedirect
	raise "HTTP redirect not supported in named_query"
      else
	response.error!
      end
    end
  end
end
