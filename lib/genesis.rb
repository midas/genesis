#$:.unshift(File.dirname(__FILE__)) unless
  #$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'genesis/active_record_extensions'
require 'genesis/railtie'
require 'genesis/schema_seed'
require 'genesis/seeder'

module Genesis
  SEEDS_ROOT = 'db/seeds'
end

#ActiveRecord::Base.send :include, Genesis::ActiveRecordExtensions if defined? ActiveRecord::Base
