require 'spec_helper'
require 'generators/genesis/install/install_generator'

describe Genesis::InstallGenerator do

  before :each do
    Genesis::InstallGenerator.start '', :destination_root => destination
  end

  after :each do
    FileUtils.rm_rf destination
  end

  let :source_root do
    Genesis::InstallGenerator.source_root
  end

  let :destination do
    File.join 'tmp', 'test_app'
  end

  {
    'genesis.rake', 'lib/tasks/genesis.rake'
  }.each do |src, dest|

    it "should copy '#{src}' to '#{dest}'" do
      File.exists?( File.join( destination, dest ) ).should be_true
    end

    it "should agree that the contents of '#{src}' are identical to '#{dest}'" do
      File.read( File.join( source_root, src ) ).should eql File.read( File.join( destination, dest ) )
    end

  end

end
