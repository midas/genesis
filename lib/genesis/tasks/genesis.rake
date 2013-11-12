namespace :db do

  desc "Loads seed data for the current environment."
  task :genesis => :environment do
    Genesis::Seeder.verify_or_create_version_table
    ignores = %w(genesis_common.rb)
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
    Genesis::Seeder.run( seeds, ENV['VERSION'] || nil, ignores )
    puts message( contexts, :using_contexts => using_contexts ), "", ""
  end

  desc "Recreates the databse by migrating down to VERSION=0 and then db:migrate and db:seed"
  task :mulligan => :environment do
    raise 'Cannot seed production' if ENV['RAILS_ENV'] == 'production' || Rails.env.production?

    Genesis::SchemaSeed.delete_all
    Rake::Task['db:reset'].invoke
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
