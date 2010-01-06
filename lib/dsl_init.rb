require 'hadoop-dsl'
require 'java'

import 'org.apache.hadoop.io.IntWritable'
import 'org.apache.hadoop.io.Text'

include HadoopDsl

# Hadoop IO types
HadoopDsl::Text = Text
HadoopDsl::IntWritable = IntWritable

def map(key, value, output, reporter, script)
  mapper = MapperFactory.create(script, key, value)
  mapper.run

  write(output, mapper)
end

def reduce(key, values, output, reporter, script)
  reducer = ReducerFactory.create(script, key, values)
  reducer.run

  write(output, reducer)
end

def setup(conf, script)
  setup = SetupFactory.create(script, conf)
  setup.run
  setup.paths
end

private

def write(output, controller)
  controller.emitted.each do |e|
    e.each do |k, v|
      output.collect(k, v)
    end
  end
end
