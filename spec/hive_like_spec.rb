require 'init'
require 'core'
require 'hive_like'

include HadoopDsl::HiveLike

describe HiveLikeSetup do
  it 'should load data' do
    script = create_tmp_script("load_data 'hive-like/inputs', items;")
    setup = HiveLikeSetup.new(script, nil)
    setup.run
    setup.paths[0].should == 'hive-like/inputs'
  end
end

describe HiveLikeMapper do
  before do
    @value = 'apple, 3, 100'
  end

  it 'should select' do
    mapper = HiveLikeMapper.new(nil, nil, @value)

    mapper.select("item", "quantity", "price", "from", "items")
    mapper.emitted.first.should == {'items' => 'apple, 3, 300'}
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
