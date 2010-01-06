module HadoopDsl
  class MapRedFactory
    def self.dsl_name(script)
      read_file(script).each_line do |line|
        dsl_name = $1 if line =~ /\s*dsl\s*\(?["'](\w*)["']\)?/
        return dsl_name if dsl_name
      end
    end

    def self.require_dsl_lib(dsl_name)
      require snake_case(dsl_name)
    end
  end

  class MapperFactory < MapRedFactory
    def self.create(script, key, value)
      dsl_name = self.dsl_name(script)
      require_dsl_lib(dsl_name)
      mapper_class = "HadoopDsl::#{dsl_name}::#{dsl_name}Mapper" 
      return eval(mapper_class).new(script, key, value)
    end
  end

  class ReducerFactory < MapRedFactory
    def self.create(script, key, values)
      dsl_name = self.dsl_name(script)
      require_dsl_lib(dsl_name)
      reducer_class = "HadoopDsl::#{dsl_name}::#{dsl_name}Reducer" 
      return eval(reducer_class).new(script, key, values)
    end
  end

  class SetupFactory < MapRedFactory
    def self.create(script, conf)
      dsl_name = self.dsl_name(script)
      require_dsl_lib(dsl_name)
      setup_class = "HadoopDsl::#{dsl_name}::#{dsl_name}Setup" 
      eval(setup_class).new(script, conf) rescue HadoopDsl::BaseSetup.new(script, conf)
    end
  end
end
