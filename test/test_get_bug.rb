require File.join(File.dirname(__FILE__), 'helper')

class Get_bug_test < Test::Unit::TestCase

  def test_get_bug
    DataMapper::Logger.new(STDOUT, :debug)
    keeper = DataMapper.setup(:default,
			      :adapter => 'bugzilla',
			      :url  => 'https://bugzilla.novell.com')

    require 'bugzilla/bug'
    DataMapper.finalize

    bug = Bug.get(424242)
    assert bug
    puts "Bug #{bug.inspect}"
  end

end
