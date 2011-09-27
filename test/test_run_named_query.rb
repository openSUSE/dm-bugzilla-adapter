require File.join(File.dirname(__FILE__), 'helper')

class Run_named_query_test < Test::Unit::TestCase

  def test_run_named_query
    DataMapper::Logger.new(STDOUT, :debug)
    keeper = DataMapper.setup(:default,
			      :adapter => 'bugzilla',
			      :url  => 'https://bugzilla.novell.com')

    require 'bugzilla/named_query'
    DataMapper.finalize

    named_query = NamedQuery.get("Manager")
    assert named_query
    bugs = named_query.bugs
    assert bugs
    puts "Query '#{named_query.name}' results in #{bugs.size} bugs"
  end

end
