# read.rb
module DataMapper::Adapters
  class BugzillaAdapter < AbstractAdapter
    require 'bugzilla/bug'
    require 'bugzilla/named_query'
    ##
    # Retrieves records for a particular model.
    #
    # @param [DataMapper::Query] query
    #   The query used to locate the resources
    #
    # @return [Array]
    #   An array of hashes of all of the records for a particular model
    #
    # @api semipublic
    def read(query)
#      STDERR.puts "BugzillaAdapter::read"
#     fields = query.fields
#      STDERR.puts "fields #{fields.inspect}"
#      types  = fields.map { |property| property.primitive }
#      STDERR.puts "types #{types.inspect}"
      records = records_for(query)
#      query.filter_records(records)
    end

  private
    # taken from https://github.com/whoahbot/dm-redis-adapter/
    
    def records_for(query)
#      STDERR.puts "records_for(#{query})"
#      STDERR.puts "records_for(#{query.inspect})"
      records = []
      if query.conditions.nil?
	raise "query.conditions.nil?" # FIXME
      else
	query.conditions.operands.each do |operand|
	  if operand.is_a?(DataMapper::Query::Conditions::OrOperation)
	    operand.each do |op|
	      records = records + perform_query(query, op)
	    end
	  else
	    records = perform_query(query, operand)
	  end
	end
      end      
      records
    end #def

    ##
    # Find records that match have a matching value
    #
    # @param [DataMapper::Query] query
    #   The query used to locate the resources
    #
    # @param [DataMapper::Operation] the operation for the query
    #
    # @return [Array]
    #   An array of hashes of all of the records for a particular model
    #
    # @api private
    def perform_query(query, operand)
#      STDERR.puts "perform_query(q '#{query}', op '#{operand}')"
      records = []
		    
      if operand.is_a?(DataMapper::Query::Conditions::NotOperation)
#	STDERR.puts "operand is a NOT operation"
	subject = operand.first.subject
	value = operand.first.value
      elsif operand.subject.is_a?(DataMapper::Associations::ManyToOne::Relationship)
#	STDERR.puts "operand subject is a many-to-one relation: '#{operand.subject.inspect}'"
	if operand.subject.parent_model == NamedQuery && operand.subject.child_model == Bug
	  name = operand.value[operand.subject.parent_key.first.name]
	  bugs = named_query(name)
	  bugs.each do |bug|
	    records << bug_to_record(query.model, bug)
	  end
	  return records
	else
	  raise "Unknown parent (#{operand.subject.parent_model}) child (#{operand.subject.child_model}) relation"
	end
      else
#	STDERR.puts "operand is normal"
	subject = operand.subject
	value =  operand.value
      end
      
      if subject.is_a?(DataMapper::Associations::ManyToOne::Relationship)
#	STDERR.puts "subject is a many-to-one relation"
	subject = subject.child_key.first
      end
      
      # typical queries
      #
      
#      STDERR.puts "perform_query(subject '#{subject.inspect}', value '#{value.inspect}')"
      case query.model.name
      when "Bug"
	if query.model.key.include?(subject)
	  # get single <bug>
	  bugs = get_bugs(value)
	  records << bug_to_record(query.model, bugs.first)
	else
	  raise "Unknown query for bug"
	end
      when "NamedQuery"
	records << { subject.name.to_s => value }
	# be lazy: do the actual named query when NamedQuery#bugs gets accessed
      else
	raise "Unsupported model '#{query.model.name}'"
      end
      
      records
    end # def

    ##
    # Convert Bicho::Bug into record (as hash of key/value pairs)
    #
    # @return [Hash]
    #   A hash of all of the properties for a particular record
    #
    #  assigned_to [String] The login name of a user that a bug is assigned to.
    #  component [String] The name of the Component that the bug is in.
    #  creation_time [DateTime] Searches for bugs that were created at this time or later. May not be an array.
    #  creator [String] The login name of the user who created the bug.
    #  id [Integer] The numeric id of the bug.
    #  last_change_time [DateTime] Searches for bugs that were modified at this time or later. May not be an array.
    #  limit [Integer] Limit the number of results returned to int records.
    #  offset [Integer] Used in conjunction with the limit argument, offset defines the starting position for the search. For example, given a search that would return 100 bugs, setting limit to 10 and offset to 10 would return bugs 11 through 20 from the set of 100.
    #  op_sys [String] The "Operating System" field of a bug.
    #  platform [String] The Platform (sometimes called "Hardware") field of a bug.
    #  priority [String] The Priority field on a bug.
    #  product [String] The name of the Product that the bug is in.
    #  creator [String] The login name of the user who reported the bug.
    #  resolution [String] The current resolution--only set if a bug is closed. You can find open bugs by searching for bugs with an empty resolution.
    #  severity [String] The Severity field on a bug.
    #  status [String] The current status of a bug (not including its resolution, if it has one, which is a separate field above).
    #  summary [String] Searches for substrings in the single-line Summary field on bugs. If you specify an array, then bugs whose summaries match any of the passed substrings will be returned.
    #  target_milestone [String] The Target Milestone field of a bug. Note that even if this Bugzilla does not have the Target Milestone field enabled, you can still search for bugs by Target Milestone. However, it is likely that in that case, most bugs will not have a Target Milestone set (it defaults to "---" when the field isn't enabled).
    #  qa_contact [String] The login name of the bug's QA Contact. Note that even if this Bugzilla does not have the QA Contact field enabled, you can still search for bugs by QA Contact (though it is likely that no bug will have a QA Contact set, if the field is disabled).
    #  url [String] The "URL" field of a bug.
    #  version [String] The Version field of a bug.
    #  whiteboard [String] Search the "Status Whiteboard" field on bugs for a substring. Works the same as the summary field described above, but searches the Status Whiteboard field.
    #
    # @api private
    def bug_to_record(model, bug)
#      STDERR.puts "bug_to_record #{bug.inspect}"
      record = { }
      model.properties.each do |p|
	v = case p.name
      when :version, :target_milestone, :op_sys, :qa_contact : bug['internals', p.name]
      when :platform : bug['internals', 'rep_platform']
      when :creator : bug['internals', 'reporter_id']
      when :whiteboard : bug['internals', 'status_whiteboard']
	else
	  bug[p.name]
	end
#	STDERR.puts "#{v.inspect} -> #{p.inspect}"
	if v
	  case p
	  when DataMapper::Property::String:   v = v.to_s
	  when DataMapper::Property::Integer:  v = v.to_i
	  when DataMapper::Property::DateTime
#	    STDERR.puts "DateTime #{v.to_a.inspect}"
	    v = DateTime.civil(*v.to_a)
#	    STDERR.puts "DateTime #{v}"
	  else
	    raise "*** Unsupported property type #{p.inspect}"
	  end
	end
	record[p.name.to_s] = v
      end
      record
    end
    
  end # class
end # module
