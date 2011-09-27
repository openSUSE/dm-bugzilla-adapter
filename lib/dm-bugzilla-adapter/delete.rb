# delete.rb
module DataMapper::Adapters
class BugzillaAdapter < AbstractAdapter
  # Constructs and executes DELETE statement for given query
  #
  # @param [Collection] collection
  #   collection of records to be deleted
  #
  # @return [Integer]
  #   the number of records deleted
  #
  # @api semipublic
							
  def delete(collection)
    each_resource_with_edit_url(collection) do |resource, edit_url|
      connection.delete(edit_url, 'If-Match' => "*")
    end
    # return count
    collection.size
  end
end
end
