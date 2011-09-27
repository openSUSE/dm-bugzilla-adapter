#
# named_query.rb
#
# A named query in Bugzilla
#
require 'rubygems'
require 'dm-core'

class NamedQuery
  include DataMapper::Resource
  property :name, String, :key => true
  has n, :bugs
end
