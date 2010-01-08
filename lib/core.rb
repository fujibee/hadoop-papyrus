require 'hadoop-dsl'
require 'forwardable'

module HadoopDsl
  # common
  module DslElement
    # all DSL statements without def is processed here
    def method_missing(method_name, *args)
      yield if block_given?
      self
    end
  end

  # controller
  module DslController
    include DslElement

    def run
      body = pre_process(HadoopDsl.read_file(@script))
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

  private
    def key; @model.key end
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

  class BaseMapper < BaseMapRed
    # common functions
    def identity
      emit(@model.key => @model.value)
    end

  private
    def value; @model.values end
  end

  class BaseReducer < BaseMapRed
    # common functions
    def aggregate
      emit(@model.key => @model.values.inject {|ret, i| ret + i})
    end

    def identity
      @model.values.each {|v| emit(@model.key => v)}
    end

  private
    def values; @model.values end
  end

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
  end

  class BaseReducerModel < BaseModel
    attr_reader :key, :values

    def initialize(key, values)
      @key, @values = key, values
    end
  end
end
