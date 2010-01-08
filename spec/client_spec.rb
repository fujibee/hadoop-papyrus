require File.join(File.dirname(__FILE__), 'spec_helper')
require 'client'

describe HadoopDsl::Client do
  before do
    @client = HadoopDsl::Client.new(["examples/wordcount.rb", "in", "out"])
  end

  it 'can parse args' do
    @client.files.join.should match /ruby_wrapper\.rb/
    @client.files.join.should match /dsl_init\.rb/
    @client.files.should include 'examples/wordcount.rb'
    @client.inputs.should == 'in'
    @client.outputs.should == 'out'
  end

  it 'can add dsl file into mapred args' do
    @client.mapred_args.should ==
      "--script dsl_init.rb in out --dslfile wordcount.rb"
  end

  it 'can add dsl lib files' do
    lib_path = HadoopDsl.lib_path
    @client.files.should include File.join(lib_path, 'core.rb')
    @client.files.should include File.join(lib_path, 'log_analysis.rb')
  end
end
