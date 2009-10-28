require 'util'

module HadoopDsl
  class MapRedFactory
    def self.dsl_name(script)
      read_file(script).each_line do |line|
        dsl_name = $1 if line =~ /^use\s*'(\w*)'/
        return dsl_name
      end
    end

    def self.require_dsl_lib(dsl_name)
      require underscore_name(dsl_name)
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
end
