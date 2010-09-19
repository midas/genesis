require 'rails/generators'

class GenesisContextsGenerator < Rails::Generators::Base
  argument :contexts, :type => :string, :default => []

  def self.source_root
    File.join( File.dirname(__FILE__), 'templates' )
  end

  def install_contexts
    @contexts.each { |context| empty_directory "#{Genesis::SEEDS_ROOT}/contexts/#{context}" }
  end
end