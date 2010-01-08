require File.join(File.dirname(__FILE__), 'spec_helper')
require 'hive_like'

include HadoopDsl::HiveLike

describe HiveLikeSetup do
  it 'should load data' do
    script = create_tmp_script(%Q!load_data "hive-like/inputs", items;!)
    conf = mock('conf')
    conf.should_receive(:output_key_class=).once
    conf.should_receive(:output_value_class=).once

    setup = HiveLikeSetup.new(script, conf)
    setup.run
    setup.paths[0].should == 'hive-like/inputs'
    setup.paths[1].should == 'hive-like/outputs'
  end
end

describe HiveLikeMapper do
  before do
    @value = 'apple, 3, 100'
  end

  it 'should create table' do
    mapper = HiveLikeMapper.new(nil, nil, @value)
    mapper.create_table('items', 'item', 'STRING', 'quantity', 'INT', 'price', 'INT');
    mapper.table.name.should == 'items'
    mapper.table.column(0).should == 'item'
    mapper.table.column(1).should == 'quantity'
  end

  it 'should select' do
    mapper = HiveLikeMapper.new(nil, nil, @value)
    mapper.create_table('items', 'item', 'STRING', 'quantity', 'INT', 'price', 'INT');
    mapper.select("item", "quantity", "price", "from", "items")
    mapper.emitted.first.should == {'items' => 'apple, 3, 100'}
  end

  it 'should pre process script body' do
    body = "select foo, bar from table;\n"
    mapper = HiveLikeMapper.new(nil, nil, @value)
    processed = mapper.pre_process(body)
    processed.should == %Q!select("foo", "bar", "from", "table")\n!
  end
end

describe HiveLikeReducer do
  it 'should select as identity' do
    key = 'Lorem'
    values = [1, 1, 1]
    reducer = HiveLikeReducer.new(nil, key, values)

    reducer.select
    reducer.emitted[0].should == {'Lorem' => 1}
  end
end
