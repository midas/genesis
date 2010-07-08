require 'rails/generators'

class GenesisGenerator < Rails::Generators::Base
  #source_root File.join( File.dirname(__FILE__), 'templates' )
  argument :seed_name, :type => :string
  argument :env, :type => :string, :default => ''
  
  def self.source_root
    File.join( File.dirname(__FILE__), 'templates' )
  end
  
  def install_seed
    template "migration.erb", "db/seeds/#{env_str}#{timestamp}_#{file_name}.rb"
  end
  
private  
  
  def file_name  
    seed_name.underscore  
  end
  
  def class_name
    seed_name.camelcase
  end
  
  def timestamp
    DateTime.now.strftime( "%Y%m%d%H%M%S" )
  end
  
  def env_str
    return env.blank? ? '' : "#{env}/"
  end
end