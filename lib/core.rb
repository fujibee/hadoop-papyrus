require 'util'
require 'forwardable'

module HadoopDsl
  # controller
  class BaseMapRed
    extend Forwardable

    attr_reader :emitted

    def initialize(script, model)
      @script, @model = script, model
      @model.controller = self
      @emitted = []
    end

    def run
      body = pre_process(read_file(@script))
      eval(body, binding, @script)
    end

    def pre_process(body)
      body # do nothing
    end

    def emit(hash) @emitted << hash end

    # all DSL statements without def is processed here
    def method_missing(method_name, *args) self end
  end

  class BaseSetup
    def initialize(script, conf)
      @script, @conf = script, conf
    end

    def run
      eval(read_file(@script), binding, @script)
    end

    def paths; [@from, @to] end

    def from(path) @from = path end
    def to(path) @to = path end

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

    # common functions
    def identity
      @controller.emit(@key => @value)
    end
  end

  class BaseReducerModel < BaseModel
    attr_reader :key, :values

    def initialize(key, values)
      @key, @values = key, values
    end

    # common functions
    def aggregate
      @controller.emit(@key => @values.inject {|ret, i| ret + i})
    end

    def identity
      @values.each {|v| @controller.emit(@key => v)}
    end
  end
end
