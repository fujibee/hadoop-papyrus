module HadoopDsl
  class Client < JRubyOnHadoop::Client
    def parse_args
      super
      @script_path = HadoopDsl.dsl_init_script
      @script = File.basename(@script_path)
      @dsl_file_path = @args[0]
      @files << @script_path << @dsl_file_path
    end

    def mapred_args
      args = super
      args += " --dslfile #{@dsl_file_path}"
      args
    end
  end
end
