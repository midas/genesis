require 'genesis/railtie' if defined?( Rails )

module Genesis

  SEEDS_ROOT = 'db/seeds'

  autoload :ActiveRecordExtensions, 'genesis/active_record_extensions'
  autoload :SchemaSeed,             'genesis/schema_seed'
  autoload :Seeder,                 'genesis/seeder'

end
