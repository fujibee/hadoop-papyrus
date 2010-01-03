require 'java'
require 'dsl_init'

import 'org.apache.hadoop.io.IntWritable'
import 'org.apache.hadoop.io.Text'
import 'org.apache.hadoop.mapred.JobConf'

describe 'mapreduce init' do

  before(:all) do
    @script = create_tmp_script(<<-EOF)
use 'LogAnalysis'
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
    @one = IntWritable.new(1)
    @output = mock('output')
  end

  it 'can map sucessfully' do
    key, value  = Text.new, Text.new
    key.set("key")
    value.set('it should be fine')
    @output.should_receive(:collect).once #.with(@text, @one)

    map(key, value, @output, nil, @script)
  end

  it 'can reduce sucessfully' do
    key, value = Text.new, Text.new
    key.set("t1\tkey")
    values = [@one, @one, @one]
    @output.should_receive(:collect).once #.with(@text, @one)

    reduce(key, values, @output, nil, @script)
  end

  it 'can set job conf' do
    conf = JobConf.new
    paths = setup(conf, @script)

    paths[0].should == 'test/inputs'
    paths[1].should == 'test/outputs'
  end
end
