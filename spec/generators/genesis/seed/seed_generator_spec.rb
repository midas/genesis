require 'spec_helper'
require 'generators/genesis/seed/seed_generator'

describe Genesis::SeedGenerator do

  with_args 'create_users' do

    xit "should generate the correct seed file" do
      # subject.should generate( // )# { |content|
        # content.should == File.read( File.join( source_root, src ) )
      # }
    end

  end

  with_args 'create_users production' do

    xit "should generate the correct seed file" do
      # subject.should generate( // )# { |content|
        # content.should == File.read( File.join( source_root, src ) )
      # }
    end

  end

  with_args '--help' do

    it "should ouput the correct description in the help message" do
      subject.should output( "Description:\n  Creates the specified seed file (optionally within a specificied environment)." )
    end

  end

end
