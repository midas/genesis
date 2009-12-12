module Genesis
  class Seeder
    def self.verify_or_create_version_table
      unless seed_version_table_exists?
        load( File.join(File.expand_path(File.dirname(__FILE__)), 'create_schema_seeds.rb') )
        Genesis::CreateSchemaSeeds.up
      end

      load( File.join(File.expand_path(File.dirname(__FILE__)), 'schema_seed.rb') )
    end

    def self.empty_revisions_table
      if seed_version_table_exists?
        load( File.join(File.expand_path(File.dirname(__FILE__)), 'schema_seed.rb') )
        SchemaSeed.delete_all
      end
    end

    def self.seed_version_table_exists?
      ActiveRecord::Base.connection.tables.include?( 'schema_seeds' )
    end

    def self.run( seeds, to_version=nil, ignores=[] )
      ignores << 'genesis_callbacks.rb'
      @separator_size = 100
      determine_current_version
      map_versions( seeds, ignores )
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
      versions = @versions_map.sort
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
      current_seed = SchemaSeed.find( :last, :order => :version )
      @current_version = current_seed.nil? ? '' : current_seed.version
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
      callbacks = File.join( RAILS_ROOT, 'db', 'seeds', 'genesis_callbacks.rb' )
      if File.exists?( callbacks )
        load( callbacks )
        should_run_callbacks = true
        callback_method = :"before_#{@method}"
        GenesisCallbacks.send( callback_method ) if GenesisCallbacks.respond_to?( callback_method )
      end

      @to_run.each { |version, metadata| self.run_seed( version, metadata ) }

      if should_run_callbacks
        callback_method = :"after_#{@method}"
        GenesisCallbacks.send( callback_method ) if GenesisCallbacks.respond_to?( callback_method )
      end
    end

    def self.run_seed( version, metadata )
      class_name = metadata[0].camelcase
      file_name = metadata[1]
      load( file_name )
      klass = class_name.constantize
      start_time = Time.now
      log_entry_start( class_name )
      klass.send( @method )
      if @method == :up
        SchemaSeed.create!( :version => version )
      else
        schema_seed = SchemaSeed.find( :first, :conditions => { :version => version } )
        schema_seed.destroy unless schema_seed.nil?
      end
      log_entry_finish( class_name, Time.now - start_time )
    end

    def self.log_entry_start( class_name )
      entry = "\n==  #{class_name}: seeding (#{@method.to_s}) "
      entry << "="*(@separator_size-entry.length+1) << "\n"
      puts entry
      RAILS_DEFAULT_LOGGER.info entry
    end

    def self.log_entry_finish( class_name, total_time )
      entry = "==  #{class_name}: seeded (#{@method.to_s}) (#{total_time}s) "
      entry << "="*(@separator_size-entry.length) << "\n"
      puts entry
      RAILS_DEFAULT_LOGGER.info entry
    end
  end
end