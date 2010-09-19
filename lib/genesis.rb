$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'genesis/active_record_extensions'
require 'genesis/seeder'
require 'genesis/schema_seed'

module Genesis
  VERSION = '1.2.0'
  SEEDS_ROOT = 'db/seeds'
end

ActiveRecord::Base.send :include, Genesis::ActiveRecordExtensions if defined? ActiveRecord::Base