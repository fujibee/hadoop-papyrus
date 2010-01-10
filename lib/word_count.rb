require 'hadoop_dsl'
require 'enumerator'

module HadoopDsl::WordCount
  MODEL_METHODS = []
  TOTAL_PREFIX = "\t"

  # controller
  class WordCountMapper < HadoopDsl::BaseMapper
    def initialize(script, key, value)
      super(script, WordCountMapperModel.new(key, value))
    end

    # model methods
    def_delegators :@model, *MODEL_METHODS

    # emitters
    def count_uniq
      @model.value.split.each {|word| emit(word => 1)}
    end

    def total(*types)
      types.each do |type|
        case type
        when :bytes
          emit("#{TOTAL_PREFIX}total bytes" => @model.value.gsub(/\s/, '').length)
        when :words
          emit("#{TOTAL_PREFIX}total words" => @model.value.split.size)
        when :lines
          emit("#{TOTAL_PREFIX}total lines" => 1)
        end
      end
    end
  end

  class WordCountReducer < HadoopDsl::BaseReducer
    def initialize(script, key, values)
      super(script, WordCountReducerModel.new(key, values))
    end

    # model methods
    def_delegators :@model, *MODEL_METHODS

    # emitters
    def count_uniq; aggregate unless @model.total_value? end
    def total(*types); aggregate if @model.total_value? end
  end

  # model
  class WordCountMapperModel < HadoopDsl::BaseMapperModel
  end

  class WordCountReducerModel < HadoopDsl::BaseReducerModel
    def total_value?; @key =~ /^#{TOTAL_PREFIX}/ end
  end
end
