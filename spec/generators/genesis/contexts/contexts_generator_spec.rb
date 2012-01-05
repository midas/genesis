require 'spec_helper'
require 'generators/genesis/contexts/contexts_generator'

describe Genesis::ContextsGenerator do

  with_args 'test1' do

    it "should generate the db/seeds/test1 folder" do
      subject.should generate( 'db/seeds/contexts/test1' )
    end

  end

  with_args 'test1,test2' do

    %w(
      db/seeds/contexts/test1
      db/seeds/contexts/test2
    ).each do |folder_path|

      it "should generate the #{folder_path} folder" do
        subject.should generate( folder_path )
      end

    end

  end

  with_args '--help' do

    it "should ouput the correct description in the help message" do
      subject.should output( "Description:\n  Generate one or more context folders." )
    end

  end

end
