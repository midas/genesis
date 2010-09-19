class PrepareSeedingGenerator < Rails::Generator::Base
  attr_accessor :opts
  attr_accessor :environments

  def initialize( runtime_args, runtime_options = {} )
    super
    @opts = {}
    @environments = []
    parse_args( args )
  end

  def manifest
    record do |m|
      m.directory 'db/seeds'
      @environments.each { |env| m.directory "db/seeds/#{env}" }
      m.file 'genesis.rake', 'lib/tasks/genesis.rake'
      m.file 'genesis_callbacks.rb', 'db/seeds/genesis_callbacks.rb'
    end
  end

  private

  def parse_args( arguments )
    arguments.each do |arg|
      arg_parts = arg.split( ':' )
      if arg_parts[0] == 'env'
        handle_env_arg( arg_parts[1] )
      else
        opts[arg_parts[0].to_sym] = arg_parts[1]
      end
    end

    validate_env_args
  end

  def handle_env_arg( val )
    if val.include?( '[' ) && val.include?( ']')
      val.gsub!( /\[/, '' ).gsub!( /\]/, '' )
      val.split( ',' ).each { |v| @environments << v.trim.gsub( /,/, '' ) }
    elsif val.include?( '[' ) || val.include?( ']' )
      raise 'Error The env option must be formatted without any spaces in the array. ie. env:[development,production]'
    elsif val.include?( ',' )
      raise 'Error The env option must be formatted with braces at the beginning and end of the list. ie. env:[development,production]'
    else
      @environments << val
    end
  end

  def validate_env_args
    @environments += %w(development production) if @environments.empty?
  end
end