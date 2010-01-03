require 'core'
require 'word_count'

include HadoopDsl::WordCount

describe WordCountMapper do
  it 'should count uniq' do
    value = 'Lorem ipsum Lorem sit amet,'
    mapper = WordCountMapper.new(nil, nil, value)

    mapper.count_uniq
    mapper.emitted[0].should == {'Lorem' => 1}
    mapper.emitted[1].should == {'ipsum' => 1}
    mapper.emitted[2].should == {'Lorem' => 1}
  end

  it 'should count total bytes' do
    value = 'Lorem ipsum Lorem sit amet,'
    mapper = WordCountMapper.new(nil, nil, value)

    mapper.total :bytes
    mapper.emitted[0].should == {"#{TOTAL_PREFIX}total bytes" => 23}
  end

  it 'should count total words' do
    value = 'Lorem ipsum Lorem sit amet,'
    mapper = WordCountMapper.new(nil, nil, value)

    mapper.total :words
    mapper.emitted[0].should == {"#{TOTAL_PREFIX}total words" => 5}
  end

  it 'should count total lines' do
    value = 'Lorem ipsum Lorem sit amet,'
    mapper = WordCountMapper.new(nil, nil, value)

    mapper.total :lines
    mapper.emitted[0].should == {"#{TOTAL_PREFIX}total lines" => 1}
  end

  it 'should count total bytes, words, lines' do
    value = 'Lorem ipsum Lorem sit amet,'
    mapper = WordCountMapper.new(nil, nil, value)

    mapper.total :bytes, :words, :lines
    mapper.emitted[0].should == {"#{TOTAL_PREFIX}total bytes" => 23}
    mapper.emitted[1].should == {"#{TOTAL_PREFIX}total words" => 5}
    mapper.emitted[2].should == {"#{TOTAL_PREFIX}total lines" => 1}
  end
end

describe WordCountReducer do
  it 'should count uniq' do
    key = 'Lorem'
    values = [1, 1, 1]
    reducer = WordCountReducer.new(nil, key, values)

    reducer.count_uniq
    reducer.emitted[0].should == {'Lorem' => 3}
  end

  it 'should count total bytes' do
    key = "#{TOTAL_PREFIX}total bytes"
    values = [12, 23, 45]
    reducer = WordCountReducer.new(nil, key, values)

    reducer.total :bytes
    reducer.emitted[0].should == {"#{TOTAL_PREFIX}total bytes" => 12 + 23 + 45}
  end

  it 'should count total words' do
    key = "#{TOTAL_PREFIX}total words"
    values = [3, 4, 5]
    reducer = WordCountReducer.new(nil, key, values)

    reducer.total :words
    reducer.emitted[0].should == {"#{TOTAL_PREFIX}total words" => 3 + 4 + 5}
  end

  it 'should count total lines' do
    key = "#{TOTAL_PREFIX}total lines"
    values = [1, 2, 3]
    reducer = WordCountReducer.new(nil, key, values)

    reducer.total :lines
    reducer.emitted[0].should == {"#{TOTAL_PREFIX}total lines" => 6}
  end
end
