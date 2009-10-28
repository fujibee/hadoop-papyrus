require File.dirname(__FILE__) + '/spec_helper'

require 'java'
require 'init'

import 'org.apache.hadoop.io.IntWritable'
import 'org.apache.hadoop.io.Text'

describe 'mapreduce init' do

  before(:all) do
    @script = create_tmp_script(<<-EOF)
use 'LogAnalysis'
data.separate(" ")
column[2].count_uniq
    EOF
  end

  before do
    @one = IntWritable.new(1)
    @output = mock('output')
  end

  it 'can map sucessfully' do
    key = Text.new
    key.set("key")
    value = Text.new
    value.set('it should be fine')
    @output.should_receive(:collect).once #.with(@text, @one)

    map(@script, key, value, @output, nil)
  end

  it 'can reduce sucessfully' do
    key = Text.new
    key.set("col2\tkey")
    value = Text.new
    values = [@one, @one, @one]
    @output.should_receive(:collect).once #.with(@text, @one)

    reduce(@script, key, values, @output, nil)
  end

end
