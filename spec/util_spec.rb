require File.join(File.dirname(__FILE__) , 'spec_helper')

require 'util'

describe 'utilities' do
  it 'can change camelcase str to snakecase' do
    snake_case('CamelCaseStr').should == 'camel_case_str'
  end

  it 'can read file and get file data to string' do
    script_body = 'This is a script body.'
    @script = create_tmp_script(script_body)
    read_file(@script).should == script_body
  end

  it 'raise error if no file in loadpath' do
    lambda { read_file('not_exists_on_loadpath') }.should raise_error
  end
end
