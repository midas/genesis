namespace :db do
  desc "Loads seed data for the current environment."
  task :genesis => :environment do
    Genesis::Seeder.verify_or_create_version_table
    ignores = %w(genesis_common.rb)
    seeds = Dir[File.join( Rails.root, 'db', 'seeds', '*.rb' )] +
            Dir[File.join( Rails.root, 'db', 'seeds', Rails.env, '*.rb') ]

    contexts = ENV['CONTEXTS']
    unless contexts.nil? || contexts.empty?
      contexts = expand_contexts if contexts == 'all'
      contexts.split( ',' ).each do |context|
        seeds += Dir[File.join( Rails.root, 'db', 'seeds', 'contexts', context, '*.rb' )]
      end
    end

    Genesis::Seeder.run( seeds, ENV['VERSION'] || nil, ignores )
  end

  desc "Drops and recreates all tables along with seeding the database"
  task :mulligan => :environment do
    Rake::Task['db:migrate:reset'].invoke
    Rake::Task['db:genesis'].invoke
  end

  desc "An alias for the db:genesis task"
  task :seed => :environment do
    Rake::Task['db:genesis'].invoke
  end

  desc "An alias for the db:regenesis task"
  task :reseed => :environment do
    Rake::Task['db:regenesis'].invoke
  end

  desc "Removes all data, runs migrations and then seeds the database"
  task :regenesis => :environment do
    ActiveRecord::Base.connection.tables.select { |t| !['schema_migrations', 'schema_seeds', 'versions', 'sessions'].include?( t ) }.each do |table|
      puts "Emptying the #{table} table"
      klass = table.classify.to_s.constantize
      klass.delete_all
    end

    puts ''

    Genesis::SchemaSeed.delete_all
    ActiveRecord::Base.connection.execute( 'DELETE FROM `versions`' )
    ActiveRecord::Base.connection.execute( 'DELETE FROM `sessions`' )

    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
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
