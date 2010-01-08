# utility functions
require 'hadoop-dsl'

module HadoopDsl
  def self.snake_case(str)
    str.gsub(/\B[A-Z]/, '_\&').downcase
  end

  def self.read_file(file_name)
    # read as usual
    body = File.open(file_name).read rescue nil
    return body if body

    # read from loadpath
    $:.each do |path|
      body = File.open(File.join(path, file_name)).read rescue next
      return body if body
    end

    raise "cannot find file - #{file_name}"
  end
end
