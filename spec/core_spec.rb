require 'dsl_init'
require 'core'

include HadoopDsl

describe 'BaseMapRed' do
  before(:all) do
    @script = create_tmp_script(<<-EOF)
from 'test/inputs'
to 'test/outputs'
    EOF
  end

  it 'emit key value' do
    mapper = BaseMapper.new(@script, BaseMapperModel.new(nil, nil))
    mapper.emit('key' => 'value')
    mapper.emitted.should == [{'key' => 'value'}]
  end

  it 'can run BaseMapper in minimum' do
    model = BaseMapperModel.new('key', 'value')
    mapper = BaseMapper.new(@script, model)
    mapper.run
  end

  it 'can run BaseReducer in minimum' do
    model = BaseReducerModel.new('key', 'values')
    reducer = BaseReducer.new(@script, model)
    reducer.run
  end

  it 'can run BaseSetup in minimum' do
    setup = BaseSetup.new(@script, nil)
    setup.run
  end

  describe BaseMapper do
    it 'can emit as identity' do
      model = BaseMapperModel.new('key', 'value')
      mapper = BaseMapper.new(@script, model)
      model.identity

      mapper.emitted.should == [{'key' => 'value'}] 
    end
  end

  describe BaseReducer do
    it 'can emit as aggregate' do
      model = BaseReducerModel.new('key', [1, 2, 3])
      reducer = BaseReducer.new(@script, model)
      model.aggregate

      reducer.emitted.should == [{'key' => 6}] 
    end

    it 'can emit as identity' do
      model = BaseReducerModel.new('key', [1, 2, 3])
      reducer = BaseReducer.new(@script, model)
      model.identity

      reducer.emitted.should == [{'key' => 1}, {'key' => 2}, {'key' => 3}] 
    end
  end

  describe BaseSetup do
    it 'can get paths' do
      setup = BaseSetup.new(@script, nil)
      setup.run
      setup.paths[0].should == 'test/inputs'
      setup.paths[1].should == 'test/outputs'
    end
  end
end
