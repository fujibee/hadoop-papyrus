require File.join(File.dirname(__FILE__) , 'spec_helper')
require 'mapred_factory'

include HadoopDsl

describe 'MapRed Factory' do
  before(:all) do
    @script = create_tmp_script("dsl 'LogAnalysis'")
  end

  it 'can create mapper' do
    mapper = MapperFactory.create(@script, nil, nil)
    mapper.class.should == LogAnalysis::LogAnalysisMapper
  end

  it 'can create reducer' do
    reducer = ReducerFactory.create(@script, nil, nil)
    reducer.class.should == LogAnalysis::LogAnalysisReducer
  end

  it 'can create setup' do
    conf = mock('conf')
    conf.should_receive(:output_key_class=).once
    conf.should_receive(:output_value_class=).once
    s = SetupFactory.create(create_tmp_script("dsl 'HiveLike'"), conf)
    s.class.should == HiveLike::HiveLikeSetup
  end

  it 'can create base if not exists in specific DSL' do
    s = SetupFactory.create(create_tmp_script("dsl 'WordCount'"), nil)
    s.class.should == BaseSetup
  end

  it 'specify dsl name from script' do
    dsl_name = MapRedFactory.dsl_name(@script)
    dsl_name.should == 'LogAnalysis'
  end

  it 'can convert dsl name to dsl lib file and require' do
    dsl_name = MapRedFactory.dsl_name(@script)
    MapRedFactory.require_dsl_lib(dsl_name).should_not be_nil
    LogAnalysis::LogAnalysisMapper
  end

  it 'can create mapper if statement has double quote' do
    script = create_tmp_script(%Q!dsl "LogAnalysis"!)
    mapper = MapperFactory.create(script, nil, nil)
    mapper.class.should == LogAnalysis::LogAnalysisMapper
  end

  it 'can create mapper if exists more space' do
    script = create_tmp_script(%Q!  dsl   "LogAnalysis"   !)
    mapper = MapperFactory.create(script, nil, nil)
    mapper.class.should == LogAnalysis::LogAnalysisMapper
  end

  it 'can create mapper if exists bracket' do
    script = create_tmp_script(%Q!  dsl ("LogAnalysis")   !)
    mapper = MapperFactory.create(script, nil, nil)
    mapper.class.should == LogAnalysis::LogAnalysisMapper
  end
end
