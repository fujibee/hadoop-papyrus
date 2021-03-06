require 'log_analysis'
require 'word_count'
require 'hive_like'

include HadoopDsl::LogAnalysis
describe 'Aapach Log Example' do
  before(:all) do
    @script = File.join(File.dirname(__FILE__), '..', 'examples', 'log_analysis_test.rb')
    @bot_ua = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    @value = %Q!127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "-" "#{@bot_ua}"!
  end

  it 'can run example by mapper' do
    mapper = LogAnalysisMapper.new(@script, nil, @value)
    mapper.run
    mapper.emitted.first.should == {"ua\t#{@bot_ua}" => 1}
  end

  it 'can run example by reducer' do
    reducer = LogAnalysisReducer.new(@script, "ua\tChrome", [1, 1, 1])
    reducer.run
    reducer.emitted.first["ua\tChrome"].should == 3
  end
end

include HadoopDsl::WordCount
describe 'Word Count Example' do
  before(:all) do
    @script = File.join(File.dirname(__FILE__), '..', 'examples', 'word_count_test.rb')
    @value = 'Lorem ipsum ipsum Lorem sit amet,'
  end

  it 'can run example by mapper' do
    mapper = WordCountMapper.new(@script, nil, @value)
    mapper.run
    mapper.emitted.size.should == 9
    mapper.emitted.each do |e|
      case e.keys.first
      when 'Lorem'
        e.values.first.should == 1
      when 'total words'
        e.values.first.should == 6
      end
    end
  end

  it 'can run example by reducer' do
    reducer = WordCountReducer.new(@script, "Lorem", [1, 1, 1])
    reducer.run
    reducer.emitted.first["Lorem"].should == 3
  end
end

include HadoopDsl::HiveLike
describe 'Hive Like Example' do
  before(:all) do
    @script = File.join(File.dirname(__FILE__), '..', 'examples', 'hive_like_test.rb')
    @value = 'apple, 3, 100'
  end

  it 'can run setup' do
    conf = mock('conf')
    conf.should_receive(:output_key_class=).once
    conf.should_receive(:output_value_class=).once

    setup = HiveLikeSetup.new(@script, conf)
    setup.run
    setup.paths[0].should == 'hive-like/items.txt'
  end

  it 'can run example by mapper' do
    mapper = HiveLikeMapper.new(@script, nil, @value)
    mapper.run
    mapper.emitted.size.should == 1
    mapper.emitted.first['items'].should == '3, 100, apple'
  end

  it 'can run example by reducer' do
    values = ['v1', 'v2', 'v3']
    reducer = HiveLikeReducer.new(@script, "items", values)
    reducer.run
    reducer.emitted.first["items"].should == 'v1'
  end
end
