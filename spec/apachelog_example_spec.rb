require 'log_analysis'

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
    values = [1, 1, 1]
    reducer = LogAnalysisReducer.new(@script, "user\tfrank", [1, 1, 1])
    reducer.run
    reducer.emitted.first["user\tfrank"].should == 3
  end
end
