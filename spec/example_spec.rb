require 'log_analysis'
require 'word_count'

include HadoopDsl::LogAnalysis
describe 'Aapach Log Example' do
  before(:all) do
    @script = File.join(File.dirname(__FILE__), '..', 'examples', 'apachelog-v2.rb')
    @value = '127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326'
  end

  it 'can run example by mapper' do
    mapper = LogAnalysisMapper.new(@script, nil, @value)
    mapper.run
    mapper.emitted.first["user\tfrank"].should == 1
  end

  it 'can run example by reducer' do
    reducer = LogAnalysisReducer.new(@script, "user\tfrank", [1, 1, 1])
    reducer.run
    reducer.emitted.first["user\tfrank"].should == 3
  end
end

include HadoopDsl::WordCount
describe 'Word Count Example' do
  before(:all) do
    @script = File.join(File.dirname(__FILE__), '..', 'examples', 'word_count.rb')
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