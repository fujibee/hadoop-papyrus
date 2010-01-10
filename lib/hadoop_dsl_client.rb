module HadoopDsl
  def self.lib_path
    File.expand_path(File.dirname(__FILE__))
  end

  def self.dsl_init_script
    File.join(lib_path, "dsl_init.rb")
  end

  class Client < JRubyOnHadoop::Client
    def parse_args
      super
      @script_path = HadoopDsl.dsl_init_script
      @script = File.basename(@script_path)
      @dsl_file_path = @args[0]
      @dsl_file = File.basename(@dsl_file_path)
      @files << @script_path << @dsl_file_path

      # TODO move properly, with jruby-on-hadoop
      add_dsl_lib_files
      ENV['RUBYLIB'] = File.dirname(@dsl_file_path)
    end

    def mapred_args
      args = super
      args += " --dslfile #{@dsl_file}"
      args
    end

    def add_dsl_lib_files
      lib_path = HadoopDsl.lib_path
      @files += Dir.glob(File.join(lib_path, "*.rb"))
    end
  end
end
