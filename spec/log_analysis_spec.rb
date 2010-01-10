require File.join(File.dirname(__FILE__), 'spec_helper')
require 'log_analysis'

include HadoopDsl::LogAnalysis

describe LogAnalysisMapper do
  before do
    @apache_log = '127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326'
  end
  
  it 'should separate data by space' do
    value = 'Lorem ipsum dolor sit amet,'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')

    mapper.column[1].value.should == 'ipsum'
  end

  it 'should separate by pattern' do
    mapper = LogAnalysisMapper.new(nil, nil, @apache_log)
    mapper.pattern /(.*) (.*) (.*) \[(.*)\] (".*") (\d*) (\d*)/

    mapper.column[2].value.should == 'frank'
  end

  it 'should label column name by string' do
    mapper = LogAnalysisMapper.new(nil, nil, @apache_log)
    mapper.pattern /(.*) (.*) (.*) \[(.*)\] (".*") (\d*) (\d*)/
    mapper.column_name 'remote_host', PASS, 'user', 'access_date', 'request', 'status', 'bytes'

    mapper.column['user'].value.should == 'frank'
  end

  it 'should label column name by symbol' do
    mapper = LogAnalysisMapper.new(nil, nil, @apache_log)
    mapper.pattern /(.*) (.*) (.*) \[(.*)\] (".*") (\d*) (\d*)/
    mapper.column_name :remote_host, PASS, :user, :access_date, :request, :status, :bytes

    mapper.column[:user].value.should == 'frank'
  end

  it 'should count uniq by column' do
    value = 'count uniq'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')
    mapper.topic('t1') { mapper.count_uniq mapper.column[1] }

    mapper.emitted.should == [{"t1\tuniq" => 1}]
  end

  it 'should count uniq by value' do
    value = 'count uniq'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')
    mapper.topic('t1') { mapper.count_uniq 'orig value' }

    mapper.emitted.should == [{"t1\torig value" => 1}]
  end

  it 'should sum column value' do
    value = 'sum 123'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')
    mapper.topic('t1') { mapper.sum mapper.column[1] }

    mapper.emitted.first["t1"].should == 123
  end

  it 'has topic which returns label' do
    value = 'Lorem ipsum dolor sit amet,'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')

    topic = mapper.topic('desc', :label => 'label')
    topic.label.should == 'label'
  end
  
  it 'has topic which returns label as desc' do
    value = 'Lorem ipsum dolor sit amet,'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')

    topic = mapper.topic('desc')
    topic.label.should == 'desc'
  end

  it 'has topic which returns label as desc with space' do
    value = 'Lorem ipsum dolor sit amet,'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')

    topic = mapper.topic('desc with space')
    topic.label.should == 'desc_with_space'
  end

  it 'can select date monthly' do
    value = '2010/1/1 newyearday'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')
    mapper.column_name 'date', 'holiday'

    ['yearly', 'monthly', 'daily'].each do |term|
      mapper.topic(term) do
        mapper.select_date_by mapper.column[:date], term.to_sym
        mapper.count_uniq mapper.column[:holiday]
      end
    end
    mapper.emitted.should ==
      [
        {"yearly\t2010\tnewyearday" => 1},
        {"monthly\t201001\tnewyearday" => 1},
        {"daily\t20100101\tnewyearday" => 1}
      ]
  end
end

Topic = LogAnalysisMapperModel::Topic
describe Topic do
  it 'can get key with label' do
    t = Topic.new('label')
    t.key.should == 'label'
  end

  it 'can get key with label and elements' do
    t = Topic.new('label')
    t.key_elements << 'e1'
    t.key_elements << 'e2'
    t.key.should == "label\te1\te2"
  end
end

describe LogAnalysisReducer do
  it 'should count uniq in the topic' do
    key = "t1\tuniq"
    values = [1, 1, 1]
    reducer = LogAnalysisReducer.new(nil, key, values)
    reducer.separate(' ')
    reducer.topic('t1') { reducer.count_uniq(nil) }

    reducer.emitted.first["t1\tuniq"].should == 3
  end

  it 'should not count uniq of other topic' do
    key = "t2\tuniq"
    values = [1, 1, 1]
    reducer = LogAnalysisReducer.new(nil, key, values)
    reducer.separate(' ')
    reducer.topic('t1') { reducer.count_uniq(nil) }

    reducer.emitted.first.should be_nil
  end

  it 'should sum column value' do
    key = "t1"
    values = [123, 456, 789]
    reducer = LogAnalysisReducer.new(nil, key, values)
    reducer.separate(' ')
    reducer.topic('t1') { reducer.sum(nil) }

    reducer.emitted.first["t1"].should == 123+456+789
  end
end
