require 'rails/generators'

module Genesis

  class InstallGenerator < Rails::Generators::Base

    argument :envs, :type => :string, :default => %w(development production)

    def self.source_root
      File.join File.dirname(__FILE__),
                'templates'
    end

    def install_seeding
      envs.each { |env| empty_directory "db/seeds/#{env}" }
      copy_file 'genesis.rake', 'lib/tasks/genesis.rake'
      copy_file 'genesis_callbacks.rb', 'db/seeds/genesis_callbacks.rb'
    end

  end

end
