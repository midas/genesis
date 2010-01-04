$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'genesis/active_record_extensions'
require 'genesis/seeder'

module Genesis
  VERSION = '0.0.3'
end

ActiveRecord::Base.send :include, Genesis::ActiveRecordExtensions if defined? ActiveRecord::Base