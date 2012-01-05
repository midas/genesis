require 'spec_helper'
require 'generators/genesis/install/install_generator'

describe Genesis::InstallGenerator do

  let :source_root do
    described_class.source_root
  end

  context "with no arguments or options" do

    {
      'genesis.rake',         'lib/tasks/genesis.rake',
      'genesis_callbacks.rb', 'db/seeds/genesis_callbacks.rb'
    }.each do |src, dest|

      it "should generate the #{dest} file with the correct contents" do
        subject.should generate( dest ) { |content|
          content.should == File.read( File.join( source_root, src ) )
        }
      end

    end

    %w(
      db/seeds/production
      db/seeds/development
    ).each do |folder_path|

      it "should generate the #{folder_path} folder" do
        subject.should generate( folder_path )
      end

    end

  end


  with_args 'test1' do

    it "should generate the db/seeds/test1 folder" do
      subject.should generate( 'db/seeds/test1' )
    end

  end

  with_args 'test1,test2' do

    %w(
      db/seeds/test1
      db/seeds/test2
    ).each do |folder_path|

      it "should generate the #{folder_path} folder" do
        subject.should generate( folder_path )
      end

    end

  end

  with_args '--help' do

    it "should ouput the correct description in the help message" do
      subject.should output( "Description:\n  Installs the genesis assets necessary to create and execute seeds." )
    end

  end

end
