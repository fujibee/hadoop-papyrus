# utility functions

module HadoopDsl
  def underscore_name(camelcase_name)
    str = camelcase_name.gsub(/([A-Z])/) { '_' + $1.downcase }
    $' if str =~ /^_/ # chop if exits _ in the first letter
  end

  def read_file(file_name)
    File.open(file_name).read
  end
end
