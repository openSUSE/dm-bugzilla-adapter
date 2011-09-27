# update.rb
module DataMapper::Adapters
class BugzillaAdapter < AbstractAdapter
  # Constructs and executes UPDATE statement for given
  # attributes and a query
  #
  # @param [Hash(Property => Object)] attributes
  #   hash of attribute values to set, keyed by Property
  # @param [Collection] collection
  #   collection of records to be updated
  #
  # @return [Integer]
  #   the number of records updated
  #
  # @api semipublic
  def update(attributes, collection)
    each_resource_with_edit_url(collection) do |resource, edit_url|
      put_updated_resource(edit_url, resource)
    end
    # return count
    collection.size
  end
end
end
