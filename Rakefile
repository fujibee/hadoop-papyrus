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

