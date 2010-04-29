# spec
require 'rubygems'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  def hadoop_core_jar
    hadoop_home = ENV['HADOOP_HOME']
    Dir.glob("#{hadoop_home}/hadoop-*-core.jar").first
  end

  t.libs = ['lib']
  t.spec_opts = ['-c', '-fs', "-r #{hadoop_core_jar}"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

# jeweler
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "hadoop-papyrus"
    gemspec.summary = "Hadoop papyrus"
    gemspec.description = "Hadoop papyrus - Ruby DSL for Hadoop"
    gemspec.email = "fujibee@gmail.com"
    gemspec.homepage = "http://github.com/fujibee/hadoop-papyrus"
    gemspec.authors = ["Koichi Fujikawa"]

    gemspec.add_dependency 'jruby-on-hadoop'
    gemspec.files.exclude "spec/**/*"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

