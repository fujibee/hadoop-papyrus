require 'forwardable'

module HadoopDsl
  # common
  module DslElement
    # all DSL statements without def is processed here
    def method_missing(method_name, *args) self end
  end

  # controller
  module DslController
    include DslElement

    def run
      body = pre_process(read_file(@script))
      eval(body, binding, @script)
    end

    def pre_process(body)
      body # do nothing
    end
  end

  class BaseMapRed
    extend Forwardable
    include DslController

    attr_reader :emitted

    def initialize(script, model)
      @script, @model = script, model
      @model.controller = self
      @emitted = []
    end

    def emit(hash) @emitted << hash end
  end

  class BaseSetup
    include DslController

    def initialize(script, conf)
      @script, @conf = script, conf
      output_format
    end

    def output_format; end # do nothing
    def paths; [@from, @to] end
    def from(path) @from = path end
    def to(path) @to = path end
  end

  # currently no difference in Mapper and reducer
  class BaseMapper < BaseMapRed; end
  class BaseReducer < BaseMapRed; end

  # model
  class BaseModel
    include DslElement
    attr_accessor :controller
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
