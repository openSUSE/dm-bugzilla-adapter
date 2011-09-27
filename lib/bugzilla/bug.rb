require 'rubygems'
require 'dm-core'
class Bug
  include DataMapper::Resource

  belongs_to :named_query, :required => false

  property :id, Integer, :key => true    #  id [Integer] The numeric id of the bug.
  property :status, String               #  status [String] The current status of a bug (not including its resolution, if it has one, which is a separate field above).
  property :severity, String             #  severity [String] The Severity field on a bug.
  property :priority, String             #  priority [String] The Priority field on a bug.
  property :product, String              #  product [String] The name of the Product that the bug is in.
  property :component, String            #  component [String] The name of the Component that the bug is in.
  property :assigned_to, String          #  assigned_to [String] The login name of a user that a bug is assigned to.
  property :version, String              #  version [String] The Version field of a bug.
  property :target_milestone, String     #  target_milestone [String] The Target Milestone field of a bug. Note that even if this Bugzilla does not have the Target Milestone field enabled, you can still search for bugs by Target Milestone. However, it is likely that in that case, most bugs will not have a Target Milestone set (it defaults to "---" when the field isn't enabled).
  property :summary, String              #  summary [String] Searches for substrings in the single-line Summary field on bugs. If you specify an array, then bugs whose summaries match any of the passed substrings will be returned.
  property :creation_time, DateTime      # Searches for bugs that were created at this time or later. May not be an array.
  property :creator, String              # The login name of the user who created the bug.
  property :last_change_time, DateTime   # Searches for bugs that were modified at this time or later. May not be an array.
  property :op_sys, String               # The "Operating System" field of a bug.
  property :platform, String             # The Platform (sometimes called "Hardware") field of a bug.
  property :creator, String              # The login name of the user who reported the bug.
  property :resolution, String           # The current resolution--only set if a bug is closed. You can find open bugs by searching for bugs with an empty resolution.    
  property :qa_contact, String           # The login name of the bug's QA Contact. Note that even if this Bugzilla does not have the QA Contact field enabled, you can still search for bugs by QA Contact (though it is likely that no bug will have a QA Contact set, if the field is disabled).
  property :url, String                  # The "URL" field of a bug.
  property :whiteboard, String           # Search the "Status Whiteboard" field on bugs for a substring. Works the same as the summary field described above, but searches the Status Whiteboard field.

end
