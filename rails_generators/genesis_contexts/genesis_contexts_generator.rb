class GenesisContextsGenerator < Rails::Generator::Base
  attr_accessor :opts
  attr_accessor :environments

  def initialize( runtime_args, runtime_options={} )
    super
    @opts = {}
    @contexts = []
    parse_args( args )
  end

  def manifest
    record do |m|
      m.directory Genesis::SEEDS_ROOT
      @contexts.each { |context| m.directory "#{Genesis::SEEDS_ROOT}/contexts/#{context}" }
    end
  end

  private

  def parse_args( arguments )
    arguments.each do |arg|
      arg_parts = arg.split( ':' )
      if arg_parts[0] == 'contexts'
        handle_env_arg( arg_parts[1] )
      else
        opts[arg_parts[0].to_sym] = arg_parts[1]
      end
    end
  end

  def handle_contexts_arg( val )
    if val.include?( '[' ) && val.include?( ']')
      val.gsub!( /\[/, '' ).gsub!( /\]/, '' )
      val.split( ',' ).each { |v| @contexts << v.trim.gsub( /,/, '' ) }
    elsif val.include?( '[' ) || val.include?( ']' )
      raise 'Error The contexts option must be formatted without any spaces in the array. ie. contexts:[accounts,users]'
    elsif val.include?( ',' )
      raise 'Error The contexts option must be formatted with braces at the beginning and end of the list. ie. contexts:[accounts,users]'
    else
      @contexts << val
    end
  end
end