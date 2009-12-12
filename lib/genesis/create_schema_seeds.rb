module Genesis
  class CreateSchemaSeeds < ActiveRecord::Migration
    def self.up
      options = {}
      options.merge!(:guid => false) if defined?( UsesguidMigrations )
      create_table :schema_seeds, options do |t|
        t.string :version
      end
    end

    def self.down
      drop_table :schema_seeds
    end
  end
end