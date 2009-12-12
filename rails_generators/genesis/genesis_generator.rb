class GenesisGenerator < Rails::Generator::NamedBase
  attr_accessor :opts
  attr_accessor :environment
  attr_accessor :env_dirs
  attr_accessor :stamp
  
  def initialize( runtime_args, runtime_options={} )
    super
    @opts = {}
    @env_dirs = []
    @stamp = DateTime.now.strftime( "%Y%m%d%H%M%S" )
    parse_args( args )
  end

  def manifest
    env_str = @environment.nil? || @environment.empty? ? '' : "#{@environment}/"
    
    record do |m|
      m.directory "db/seeds"
      @env_dirs.each { |env_dir| m.directory "db/seeds/#{env_dirs}" }
      m.template  "migration.rb", "db/seeds/#{env_str}#{@stamp}_#{file_name.underscore}.rb"
    end
  end
  
  private 
  
  def parse_args( arguments )
    arguments.each do |arg|
      arg_parts = arg.split( ':' )
      if arg_parts.size > 1
        process_keyed_arg( arg_parts )
      else
        handle_env_arg( arg )
      end
    end
  end
  
  def process_keyed_arg( arg_parts )
    if arg_parts[0] == 'env'
      handle_env_arg( arg_parts[1] )
    else
      opts[arg_parts[0].to_sym] = arg_parts[1]
    end
  end
  
  def handle_env_arg( val )
    @environment = val
    @env_dirs = val
  end
end