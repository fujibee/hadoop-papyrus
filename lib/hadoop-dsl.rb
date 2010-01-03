require 'jruby-on-hadoop'
require 'client'

module HadoopDsl
  def self.lib_path
    File.expand_path(File.dirname(__FILE__))
  end

  def self.dsl_init_script
    File.join(lib_path, "dsl_init.rb")
  end
end
