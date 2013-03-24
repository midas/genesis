require 'rails/generators'

module Genesis

  class InstallGenerator < Rails::Generators::Base

    desc "Description:\n  Installs the genesis assets necessary to create and execute seeds."

    argument :environments, :type => :string, :default => %w(development production)

    def self.source_root
      File.join File.dirname(__FILE__),
                'templates'
    end

    def install_seeding
      envs.each { |env| empty_directory "db/seeds/#{env}" }
      copy_file 'genesis_callbacks.rb', 'db/seeds/genesis_callbacks.rb'
    end

    def envs
      return environments if environments.is_a?( Array )

      environments.split ','
    end

  end

end
