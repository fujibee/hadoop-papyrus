require 'core'
require 'java'
require 'mapred_factory'

import 'org.apache.hadoop.io.IntWritable'
import 'org.apache.hadoop.io.Text'

include HadoopDsl

# Hadoop IO types
HadoopDsl::Text = Text
HadoopDsl::IntWritable = IntWritable

def map(key, value, output, reporter, script)
  mapper = MapperFactory.create(script, key.to_string, value.to_string)
  mapper.run

  write(output, mapper)
end

def reduce(key, values, output, reporter, script)
  ruby_values = values.map {|v| to_ruby(v)}
  reducer = ReducerFactory.create(script, key.to_string, ruby_values)
  reducer.run

  write(output, reducer)
end

def setup(conf, script)
  setup = SetupFactory.create(script, conf)
  setup.run

  setup.paths.to_java
end

private

def write(output, controller)
  controller.emitted.each do |e|
    e.each do |k, v|
      output.collect(to_hadoop(k), to_hadoop(v))
    end
  end
end

def to_ruby(value)
  case value
  when IntWritable then value.get
  when Text then value.to_string
  else raise "no match class: #{value.class}"
  end
end

def to_hadoop(value)
  case value
  when Integer then IntWritable.new(value)
  when String then t = Text.new; t.set(value); t
  else raise "no match class: #{value.class}"
  end
end
