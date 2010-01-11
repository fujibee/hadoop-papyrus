# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hadoop-rubydsl}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Koichi Fujikawa"]
  s.date = %q{2010-01-11}
  s.description = %q{Hadoop Ruby DSL}
  s.email = %q{fujibee@gmail.com}
  s.executables = ["hrd", "hadoop-hudson.sh", "hadoop-ruby.sh"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/hadoop-hudson.sh",
     "bin/hadoop-ruby.sh",
     "bin/hrd",
     "conf/hadoop-site.xml",
     "examples/hive_like_test.rb",
     "examples/log_analysis_test.rb",
     "examples/word_count_test.rb",
     "hadoop-rubydsl.gemspec",
     "lib/core.rb",
     "lib/dsl_init.rb",
     "lib/hadoop_dsl.rb",
     "lib/hadoop_dsl_client.rb",
     "lib/hive_like.rb",
     "lib/log_analysis.rb",
     "lib/mapred_factory.rb",
     "lib/util.rb",
     "lib/word_count.rb"
  ]
  s.homepage = %q{http://github.com/fujibee/hadoop-rubydsl}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Hadoop Ruby DSL}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/dsl_init_spec.rb",
     "spec/core_spec.rb",
     "spec/client_spec.rb",
     "spec/util_spec.rb",
     "spec/mapred_factory_spec.rb",
     "spec/word_count_spec.rb",
     "spec/hive_like_spec.rb",
     "spec/log_analysis_spec.rb",
     "spec/example_spec.rb",
     "examples/hive_like_test.rb",
     "examples/log_analysis_test.rb",
     "examples/word_count_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<jruby-on-hadoop>, [">= 0"])
    else
      s.add_dependency(%q<jruby-on-hadoop>, [">= 0"])
    end
  else
    s.add_dependency(%q<jruby-on-hadoop>, [">= 0"])
  end
end

