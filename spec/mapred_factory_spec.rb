require File.join(File.dirname(__FILE__) , 'spec_helper')

require 'mapred_factory'
require 'log_analysis'

describe 'MapRed Factory' do

  before(:all) do
    @script = create_tmp_script("dsl 'LogAnalysis'")
  end

  it 'can create mapper' do
    mapper = MapperFactory.create(@script, nil, nil)
    mapper.class.should == LogAnalysisMapper
  end

  it 'can create reducer' do
    reducer = ReducerFactory.create(@script, nil, nil)
    reducer.class.should == LogAnalysisReducer
  end

  it 'can create setup' do
    s = SetupFactory.create(@script, nil)
    s.class.should == LogAnalysisSetup
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
    LogAnalysisMapper
  end

  it 'can create mapper if statement has double quote' do
    script = create_tmp_script(%Q!dsl "LogAnalysis"!)
    mapper = MapperFactory.create(script, nil, nil)
    mapper.class.should == LogAnalysisMapper
  end

  it 'can create mapper if exists more space' do
    script = create_tmp_script(%Q!  dsl   "LogAnalysis"   !)
    mapper = MapperFactory.create(script, nil, nil)
    mapper.class.should == LogAnalysisMapper
  end

  it 'can create mapper if exists bracket' do
    script = create_tmp_script(%Q!  dsl ("LogAnalysis")   !)
    mapper = MapperFactory.create(script, nil, nil)
    mapper.class.should == LogAnalysisMapper
  end
end
