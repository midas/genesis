namespace :db do
  desc "Loads seed data for the current environment."
  task :genesis => :environment do
    fixtures = (Dir[File.join( RAILS_ROOT, 'db', 'seeds', '*.rb' )] + Dir[File.join( RAILS_ROOT, 'db', 'seeds', RAILS_ENV, '*.rb') ]).sort
    fixtures.each do |fixture| 
      load fixture 
      no_extension_name = fixture.gsub!( /.rb/, '' )
      class_name = no_extension_name.match( /\d*_(\w*)/ )[1].camelcase
      klass = class_name.constantize
      klass.up
    end
  end

  desc "Drops and recreates all tables along with seeding the database"
  task :mulligan => :environment do
    ActiveRecord::Base.disable_observers
    Rake::Task['db:migrate:reset'].invoke
    Rake::Task['db:version'].invoke
    Rake::Task['db:genesis'].invoke
  end
end
