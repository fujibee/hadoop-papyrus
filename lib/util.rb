# utility functions

module HadoopDsl
  def snake_case(str)
    str.gsub(/\B[A-Z]/, '_\&').downcase
  end

  def read_file(file_name)
    File.open(file_name).read
  end
end
