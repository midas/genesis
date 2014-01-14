module Genesis
  class Seeder
    def self.load_schema_seed_model
      load( File.join(File.expand_path(File.dirname(__FILE__)), 'schema_seed.rb') )
    end

    # Verifies that the schema_seeds table exists creating if if it does not exist.
    #
    def self.verify_or_create_version_table
      unless seed_version_table_exists?
        load( File.join(File.expand_path(File.dirname(__FILE__)), 'create_schema_seeds.rb') )
        Genesis::CreateSchemaSeeds.up
      end

      load_schema_seed_model
    end

    # Deletes all records from the schema_seeds table.
    #
    def self.empty_revisions_table
      if seed_version_table_exists?
        load_schema_seed_model
        SchemaSeed.delete_all
      end
    end

    # Returns the current seed version from the schema_seeds table.
    #
    def self.get_current_version
      return 'No seed version table exists.  Assuming seed version is 0.' unless seed_version_table_exists?
      load_schema_seed_model
      determine_current_version
      return @current_version
    end

    # Checks if the schema_seeds table exists.
    #
    def self.seed_version_table_exists?
      ActiveRecord::Base.connection.tables.include?( 'schema_seeds' )
    end

    # Runs the migration process.
    #
    def self.run( seeds=[], to_version=nil, ignores=[] )
      ignores << 'genesis_callbacks.rb'
      @separator_size = 95
      determine_current_version
      map_versions( seeds, ignores )
      raise 'There are no seeds to execute.' if @versions_map.empty?
      to_version = determine_to_version( to_version )
      determine_and_prepare_seed_direction( to_version )
      if @to_run.empty?
        puts "The requested seed version (#{to_version}) resulted in no necessary seeding.  Data is up to date."
        return
      end
      run_seeds
    end

    private

    def self.determine_to_version( to_version )
      versions = @versions_map.empty? ? [] : @versions_map.sort
      return '' if to_version.blank? && versions.blank?
      return to_version.blank? ? versions[versions.size-1][0] : to_version
    end

    def self.map_versions( seeds, ignores )
      @versions_map = {}
      seeds.each do |seed|
        parts = File.split( seed )
        unless ignores.include?( parts[1] )
          matches = parts[1].match( /(\d*)_(\w*).rb/ )
          @versions_map[matches[1]] = [matches[2], seed]
        end
      end
    end

    def self.validate_version_existence( to_version )
      raise "A seed file with the version '#{to_version}' does not exist." unless @versions_map.has_key?( to_version ) || to_version == '0'
    end

    def self.determine_current_version
      current_seed = SchemaSeed.find( :last, :order => :seed_version )
      @current_version = current_seed.nil? ? '' : current_seed[:seed_version]
    end

    def self.determine_and_prepare_seed_direction( to_version )
      validate_version_existence( to_version ) if to_version
      to_version ||= ''
      @to_run = []
      return if @current_version == to_version || (@current_version.empty? && to_version == '0')
      if to_version > @current_version
        @versions_map = @versions_map.reject { |version, metadata| version <= @current_version || version > to_version}
        @to_run = @versions_map.sort
        @method = :up
      else
        @versions_map = @versions_map.reject { |version, metadata| version <= to_version }
        @to_run = @versions_map.sort { |a, b| b[0] <=> a[0] }
        @method = :down
      end
    end

    def self.parse_to_version_and_name( seed_file_name )
      no_extension_name = File.split( seed_file_name )
      matches = no_extension_name.match( /(\d*)_(\w*).rb/ )
      return matches[1], matches[2]
    end

    def self.run_seeds
      callbacks = File.join( Rails.root, 'db', 'seeds', 'genesis_callbacks.rb' )
      if File.exists?( callbacks )
        load( callbacks )
        should_run_callbacks = true
        callback_method = :"before_#{@method}"
        GenesisCallbacks.send( callback_method ) if GenesisCallbacks.respond_to?( callback_method )
      end

      @time_start_seeding = Time.now
      @to_run.each { |version, metadata| self.run_seed( version, metadata ) }
      @time_end_seeding = Time.now

      if should_run_callbacks
        callback_method = :"after_#{@method}"
        GenesisCallbacks.send( callback_method ) if GenesisCallbacks.respond_to?( callback_method )
      end

      log_seeding_finish
    end

    def self.run_seed( version, metadata )
      class_name = metadata[0].camelize
      file_name = metadata[1]
      load( file_name )
      klass = class_name.constantize
      start_time = Time.now
      log_entry_start( class_name )
      klass.send( @method )
      if @method == :up
        ActiveRecord::Base.connection.execute( "INSERT INTO schema_seeds(#{ActiveRecord::Base.connection.quote_column_name 'seed_version'}) VALUES('#{version}');" )
      else
        schema_seed = SchemaSeed.find( :first, :conditions => { :seed_version => version } )
        schema_seed.destroy unless schema_seed.nil?
      end
      log_entry_finish( class_name, Time.now - start_time )
    end

    def self.log_entry_start( class_name )
      entry = "==  #{class_name}: seeding (#{@method.to_s}) "
      entry << "="*(@separator_size-entry.length) << "\n"
      puts entry
      Rails.logger.info entry
    end

    def self.log_entry_finish( class_name, total_time )
      entry = "==  #{class_name}: seeded (#{@method.to_s}) (#{total_time}s) "
      num_to_finish = @separator_size-entry.length
      entry << "="*(num_to_finish) << "\n\n" if num_to_finish > 0
      puts entry
      Rails.logger.info entry
    end

    def self.log_seeding_finish
      entry = "*** Seeding total time: #{@time_end_seeding - @time_start_seeding}s"
      puts entry
      Rails.logger.info entry
    end
  end
end
