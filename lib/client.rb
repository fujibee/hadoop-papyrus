module HadoopDsl
  class Client < JRubyOnHadoop::Client
    def parse_args
      super
      @script_path = HadoopDsl.dsl_init_script
      @script = File.basename(@script_path)
      @dsl_file_path = @args[0]
      @files << @script_path << @dsl_file_path
      add_dsl_lib_files # TODO move properly
    end

    def mapred_args
      args = super
      args += " --dslfile #{@dsl_file_path}"
      args
    end

    def add_dsl_lib_files
      lib_path = HadoopDsl.lib_path
      @files += Dir.glob(File.join(lib_path, "*.rb"))
    end
  end
end
