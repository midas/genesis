namespace :db do
  desc "Loads seed data for the current environment."
  task :genesis => :environment do
    Genesis::Seeder.verify_or_create_version_table
    ignores = %w()
    seeds = Dir[File.join( RAILS_ROOT, 'db', 'seeds', '*.rb' )] +
            Dir[File.join( RAILS_ROOT, 'db', 'seeds', RAILS_ENV, '*.rb') ]
    Genesis::Seeder.run( seeds, ENV['VERSION'] || nil, ignores )
  end

  desc "Drops and recreates all tables along with seeding the database"
  task :mulligan => :environment do
    Rake::Task['db:migrate:reset'].invoke
    Rake::Task['db:genesis'].invoke
  end
end
