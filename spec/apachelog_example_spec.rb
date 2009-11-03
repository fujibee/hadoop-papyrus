require 'log_analysis'

include HadoopDsl::LogAnalysis

describe 'Aapach Log Example' do
  before(:all) do
    @script = File.dirname(__FILE__) + '/../examples/apachelog-v2.rb'
    @value = '127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326'
  end

  it 'can run example' do
    pending 'not many function implement yet'
    mapper = LogAnalysisMapper.new(@script, nil, @value)
    mapper.run
  end
end
