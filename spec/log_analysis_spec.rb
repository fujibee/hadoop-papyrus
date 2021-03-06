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

  it 'should separate by comma (CSV) with csv library' do
    value = '"Lorem","ip,sum","dolor","sit","amet"'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(:csv)

    require('csv').should be_false # already required
    mapper.column[1].value.should == 'ip,sum'
  end

  it 'should separate by tab char (TSV)' do
    value = "Lorem\tipsum\tdolor\tsit\tamet,"
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(:tsv)

    mapper.column[4].value.should == 'amet,'
  end

  it 'should not separate by non support separator' do
    value = 'Lorem ipsum dolor sit amet,'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    lambda { mapper.separate(:nonsupport) }.should raise_error
  end

  it 'should non-local exit if cannot separate by pattern' do
    mapper = LogAnalysisMapper.new(nil, nil, @apache_log + " a")
    mapper.each_line do
      mapper.pattern /(.*) (.*) (.*) \[(.*)\] (".*") (\d*) (\d*)$/
      fail 'should not be reached'
    end
    mapper.column[0].should be_nil
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

  it 'should just count' do
    value = 'count only'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')
    mapper.topic('t1') { mapper.count }

    mapper.emitted.should == [{"t1" => 1}]
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

  it 'can group date monthly' do
    value = "2010/1/1 21:23:10\tnewyearday"
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate("\t")
    mapper.column_name 'date', 'holiday'

    ['yearly', 'monthly', 'daily', 'hour_of_day'].each do |term|
      mapper.topic(term) do
        mapper.group_date_by mapper.column[:date], term.to_sym
        mapper.count_uniq mapper.column[:holiday]
      end
    end
    mapper.emitted.should ==
      [
        {"yearly\t2010\tnewyearday" => 1},
        {"monthly\t201001\tnewyearday" => 1},
        {"daily\t20100101\tnewyearday" => 1},
        {"hour_of_day\t21\tnewyearday" => 1}
      ]
  end

  it 'can group by' do
    value = '1 sub_2 bingo!'
    mapper = LogAnalysisMapper.new(nil, nil, value)
    mapper.separate(' ')
    mapper.column_name 'id', 'sub_id', 'data'

    mapper.topic('test') do
      mapper.group_by mapper.column[:sub_id]
      mapper.count_uniq mapper.column[:data]
    end
    mapper.emitted.should == [{"test\tsub_2\tbingo!" => 1}]
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
