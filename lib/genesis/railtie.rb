require 'genesis'
require 'rails'

class Railtie < Rails::Railtie

  initializer 'genesis.insert_into_active_record' do |app|
    ActiveSupport.on_load :active_record do
      ActiveRecord::Base.send :include, Genesis::ActiveRecordExtensions
    end
  end

  rake_tasks do
    Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
  end

end
