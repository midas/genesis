require 'spec_helper'
require 'generators/genesis/genesis_generator'

describe GenesisGenerator do

  before :each do
    @destination = File.join 'tmp', 'test_app'
    @source = GenesisGenerator.source_root
    GenesisGenerator.start '', :destination_root => @destination
  end

  after :each do
    FileUtils.rm_rf @destination
  end

  {}.each do |file, path|
    it "should copy '#{file}' to '#{path}'" do
      File.exists?( File.join( @destination, path ) ).should be_true
    end

    # it "should agree that the contents of '#{file}' are identical to '#{path}'" do
    #   File.read( File.join( @source, file ) ).should eql File.read( File.join( @destination, path ) )
    # end
  end

end
