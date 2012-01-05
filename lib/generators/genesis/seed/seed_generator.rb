require 'rails/generators'

module Genesis

  class SeedGenerator < Rails::Generators::Base

    desc "Description:\n  Creates the specified seed file (optionally within a specificied environment)."

    argument :seed_name,   :type => :string, :required => true
    argument :environment, :type => :string, :default => ''

    def self.source_root
      File.join File.dirname(__FILE__),
                'templates'
    end

    def install_seed
      template "migration.erb", "db/seeds/#{environment_part}#{timestamp}_#{file_name}.rb"
    end

  private

    def file_name
      seed_name.underscore
    end

    def class_name
      seed_name.camelcase
    end

    def timestamp
      @teimstamp ||= DateTime.now.strftime( "%Y%m%d%H%M%S" )
    end

    def environment_part
      environment.blank? ? '' : "#{environment}/"
    end

  end

end
