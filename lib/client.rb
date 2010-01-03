module HadoopDsl
  class Client < JRubyOnHadoop::Client
    def parse_args
      super
      @script_path = HadoopDsl.dsl_init_script
      @script = File.basename(@script_path)
      @dsl_file_path = @args[0]
      @dsl_file = File.basename(@dsl_file_path)
      @files << @script_path << @dsl_file_path
    end

    def mapred_args
      args = super
      args += " --dslfile #{@dsl_file}"
      args
    end
  end
end
