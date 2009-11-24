require 'core'
require 'java'
require 'mapred_factory'

import 'org.apache.hadoop.io.IntWritable'
import 'org.apache.hadoop.io.Text'

include HadoopDsl

def map(key, value, output, reporter, script)
  mapper = MapperFactory.create(script, key.to_string, value.to_string)
  mapper.run

  write(output, mapper)
end

def reduce(key, values, output, reporter, script)
  ruby_values = values.map {|v| v.get}
  reducer = ReducerFactory.create(script, key.to_string, ruby_values)
  reducer.run

  write(output, reducer)
end

private

def write(output, controller)
	text = Text.new
  controller.emitted.each do |e|
    e.each do |k, v|
      text.set(k)
      output.collect(text, IntWritable.new(v))
    end
  end
end
