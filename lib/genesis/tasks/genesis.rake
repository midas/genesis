namespace :db do

  desc "Loads seed data for the current environment."
  task :genesis => :environment do
    dry_run = ENV['DRY_RUN']

    Genesis::Seeder.verify_or_create_version_table
    ignores = %w(genesis_common.rb
                 genesis_callbacks.rb)
    seeds = Dir[File.join( Rails.root, 'db', 'seeds', '*.rb' )] +
            Dir[File.join( Rails.root, 'db', 'seeds', Rails.env, '*.rb') ]

    contexts = ENV['CONTEXTS']
    unless contexts.nil? || contexts.empty?
      using_contexts = true
      contexts = expand_contexts if contexts == 'all'
      contexts.split( ',' ).each do |context|
        seeds += Dir[File.join( Rails.root, 'db', 'seeds', 'contexts', context, '*.rb' )]
      end
    end

    puts "", message( contexts, :using_contexts => using_contexts, :start => true ), ""
    if dry_run
      r = ActiveRecord::Base.connection.execute( "SELECT `schema_seeds`.* FROM `schema_seeds`" )
      versions = []
      executes = []
      r.each_hash { |rec| versions << rec['version'] }

      puts '-- DRY RUN --', 'Will execute seeds:', ''
      seeds.reject! { |s| ignores.any? { |i| s.include?( i ) } }

      seeds.each do |s|
        match = s.match( /^.*\/((\d*)_.*\.rb)$/ )
        if match
          executes << match[1] unless versions.include?( match[2] )
        end
      end

      puts executes.sort.join( "\n" )
      puts ''
    else
      Genesis::Seeder.run( seeds, ENV['VERSION'] || nil, ignores )
    end
    puts message( contexts, :using_contexts => using_contexts ), "", ""
  end

  desc "Loads seed data for the current environment."
  task :genesis => :environment do
  end

  desc "Recreates the databse by migrating down to VERSION=0 and then db:migrate and db:seed"
  task :mulligan => :environment do
    raise 'Cannot seed production' if ENV['RAILS_ENV'] == 'production' || Rails.env.production?

    ENV['VERSION']= '0'
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:migrate'].reenable
    ENV.delete 'VERSION'
    Rake::Task["db:migrate"].invoke
    Genesis::SchemaSeed.delete_all
    Rake::Task['db:genesis'].invoke
  end

  namespace :mulligan do

    desc 'Recreates database using db:migrate:reset and db:seed (helpful when an irreversible migration is blocking db:mulligan)'
    task :reset => :environment do
      raise 'Cannot seed production' if ENV['RAILS_ENV'] == 'production' || Rails.env.production?

      Rake::Task['db:migrate:reset'].invoke
      Rake::Task['db:genesis'].invoke
    end

  end

  desc "An alias for the db:genesis task"
  task :seed => :environment do
    Rake::Task['db:genesis'].invoke
  end

  desc "An alias for the db:regenesis task"
  task :reseed => :environment do
    Rake::Task['db:regenesis'].invoke
  end

  desc "Removes all data and then seeds the database"
  task :regenesis => :environment do
    raise 'Cannot seed production' if ENV['RAILS_ENV'] == 'production' || Rails.env.production?

    ActiveRecord::Base.connection.tables.select { |t| !['schema_migrations', 'schema_seeds', 'versions', 'sessions'].include?( t ) }.each do |table|
      puts "Emptying the #{table} table"
      klass = table.classify.to_s.constantize
      klass.delete_all
    end

    puts ''

    Genesis::SchemaSeed.delete_all

    Rake::Task['db:genesis'].invoke
  end

  namespace :genesis do
    desc "Returns the current seed version from teh schema_seeds table"
    task :version => :environment do
      puts "[Genesis Seed Version] #{Genesis::Seeder.get_current_version}"
    end
  end
end

def seeds_root
  File.join( Rails.root, 'db', 'seeds' )
end

def contexts_root
  File.join( seeds_root, 'contexts' )
end

def expand_contexts
  Dir[File.join( contexts_root, '*'  )].map { |d| d.split( '/' ).last }.join ','
end

def message( contexts, options={} )
  msg = options[:using_contexts] ?
    "*** #{start_or_end_word( options )} seeding (contexts: #{contexts.split(',').join(', ')})" :
    "*** #{start_or_end_word( options )} seeding"
end

def start_or_end_word( options )
  return options[:start] ? 'Start' : 'End'
end
