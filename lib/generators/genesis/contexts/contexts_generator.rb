require 'rails/generators'

module Genesis

  class ContextsGenerator < Rails::Generators::Base

    desc "Description:\n  Generate one or more context folders."

    argument :contexts, :type => :string, :required => true

    def self.source_root
      File.join File.dirname(__FILE__),
                'templates'
    end

    def install_contexts
      normalized_contexts.each do |context|
        empty_directory File.join( Genesis::SEEDS_ROOT, 'contexts', context )
      end
    end

    def normalized_contexts
      return contexts if contexts.is_a?( Array )

      contexts.split ','
    end

  end

end
