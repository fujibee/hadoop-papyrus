# spec helper

require 'tempfile'

def create_tmp_script(body)
  tmp = Tempfile.new('test.rb')
  tmp.print body
  tmp.close
  tmp.path
end

