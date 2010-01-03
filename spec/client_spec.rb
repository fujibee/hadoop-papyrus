require 'hadoop-dsl'

describe HadoopDsl::Client do
  before do
    @client = HadoopDsl::Client.new(["examples/wordcount.rb", "in", "out"])
  end

  it 'can parse args' do
    @client.files.join.should match /ruby_wrapper\.rb/
    @client.files.join.should match /dsl_init_script\.rb/
    @client.files.should include 'examples/wordcount.rb'
    @client.inputs.should == 'in'
    @client.outputs.should == 'out'
  end

  it 'can add dsl file into mapred args' do
    @client.mapred_args.should ==
      "--script dsl_init_script.rb in out --dslfile wordcount.rb"
  end
end
