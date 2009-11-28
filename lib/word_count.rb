require 'core'
require 'enumerator'

module HadoopDsl::WordCount
  include HadoopDsl
  
  AVAILABLE_METHODS = [:count_uniq, :total]
  TOTAL_PREFIX = "\t"

  # common
  module WordCountMapRed
    # entry point
    def data(description = '', &block) yield end
  end

  # controller
  class WordCountMapper < BaseMapper
    def initialize(script, key, value)
      super(script, WordCountMapperModel.new(key, value))
    end

    include WordCountMapRed

    # model methods
    def_delegators :@model, *AVAILABLE_METHODS
  end

  class WordCountReducer < BaseReducer
    def initialize(script, key, values)
      super(script, WordCountReducerModel.new(key, values))
    end

    include WordCountMapRed

    # model methods
    def_delegators :@model, *AVAILABLE_METHODS
  end

  # model
  class WordCountMapperModel < BaseMapperModel
    def initialize(key, value)
      super(key, value)
    end

    # emitters
    def count_uniq
      @value.split.each {|word| @controller.emit(word => 1)}
    end

    def total(*types)
      types.each do |type|
        case type
        when :bytes
          @controller.emit("#{TOTAL_PREFIX}total bytes" => @value.gsub(/\s/, '').length)
        when :words
          @controller.emit("#{TOTAL_PREFIX}total words" => @value.split.size)
        when :lines
          @controller.emit("#{TOTAL_PREFIX}total lines" => 1)
        end
      end
    end
  end

  class WordCountReducerModel < BaseReducerModel
    def initialize(key, values)
      super(key, values)
    end

    # emitters
    def count_uniq; aggregate unless total_value? end
    def total(*types); aggregate if total_value? end

    private
    def total_value?; @key =~ /^#{TOTAL_PREFIX}/ end
  end
end
