require 'util'

module HadoopDsl
  # controller
  class BaseMapRed
    attr_reader :emitted

    def initialize(script, model)
      @script, @model = script, model
      @model.controller = self
      @emitted = []
    end

    def run
      eval(read_file(@script), binding, @script)
    end

    def emit(hash)
      @emitted << hash
    end

    # all DSL statements without def is processed here
    def method_missing(method_name, *args) self end
  end

  class BaseMapper < BaseMapRed
    def initialize(script, model)
      super(script, model)
    end
  end

  class BaseReducer < BaseMapRed
    def initialize(script, model)
      super(script, model)
    end
  end

  # model
  class BaseModel
    attr_accessor :controller

    # all DSL statements without def is processed here
    def method_missing(method_name, *args) self end
  end

  class BaseMapperModel < BaseModel
    attr_reader :key, :value

    def initialize(key, value)
      @key, @value = key, value
    end
  end

  class BaseReducerModel < BaseModel
    attr_reader :key, :values

    def initialize(key, values)
      @key, @values = key, values
    end
  end
end
