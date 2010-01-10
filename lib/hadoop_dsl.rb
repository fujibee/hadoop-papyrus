require 'jruby-on-hadoop'
require 'hadoop_dsl_client'
require 'util'
require 'mapred_factory'
require 'core'

# for jruby
if defined? JRUBY_VERSION
  require 'java'
  import 'org.apache.hadoop.io.IntWritable'
  import 'org.apache.hadoop.io.Text'

  # Hadoop IO types
  HadoopDsl::Text = Text
  HadoopDsl::IntWritable = IntWritable
end
