$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'test/unit'
require 'dm-bugzilla-adapter'

if ENV["DEBUG"]
  Bicho::Logging.logger = Logger.new(STDERR)
  Bicho::Logging.logger.level = Logger::DEBUG
end
