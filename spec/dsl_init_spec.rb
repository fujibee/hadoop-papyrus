require 'dsl_init'

describe 'mapreduce init' do

  before(:all) do
    @script = create_tmp_script(<<-EOF)
dsl 'LogAnalysis'
data 'test' do
  from 'test/inputs'
  to 'test/outputs'

  separate(" ")
  column_name 'c0', 'c1', 'c2', 'c3'
  topic 't1' do
    count_uniq columns(:c1)
  end
end
    EOF
  end

  before do
    @one = 1
    @output = mock('output')
  end

  it 'can map sucessfully' do
    key = 'key'
    value = 'it should be fine'
    @output.should_receive(:collect).once #.with(@text, @one)

    map(key, value, @output, nil, @script)
  end

  it 'can reduce sucessfully' do
    key = "t1\tkey"
    values = [@one, @one, @one]
    @output.should_receive(:collect).once #.with(@text, @one)

    reduce(key, values, @output, nil, @script)
  end

  it 'can set job conf' do
    conf = mock('jobconf')
    paths = setup(conf, @script)

    paths[0].should == 'test/inputs'
    paths[1].should == 'test/outputs'
  end
end
