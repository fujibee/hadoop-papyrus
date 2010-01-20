# utility functions
require 'hadoop_dsl'

module HadoopDsl
  # file body cache
  # reading file in map/reduce cause critical issues!
  @@file_bodies = {}

  def self.snake_case(str)
    str.gsub(/\B[A-Z]/, '_\&').downcase
  end

  def self.read_file(file_name)
    # use if cached
    body = @@file_bodies[file_name] if @@file_bodies[file_name]

    # read as usual
    body = File.open(file_name).read rescue nil unless body

    # read from loadpath
    unless body
      $:.each do |path|
        body = File.open(File.join(path, file_name)).read rescue next
        break
      end
    end

    raise "cannot find file - #{file_name}" unless body

    # for cache
    @@file_bodies[file_name] = body
    body
  end

  def self.reset_dsl_file
    @@file_bodies = {}
  end
end
