require 'core'
require 'enumerator'

module HadoopDsl::LogAnalysis
  include HadoopDsl
  
  KEY_SEP = "\t"
  PREFIX = 'col'
  AVAILABLE_METHODS = [:separate, :pattern, :column, :count_uniq, :sum]

  # common
  module LogAnalysisMapRed
    # entry point
    def data(description = '', &block) yield end
  end

  # controller
  class LogAnalysisMapper < BaseMapper
    def initialize(script, key, value)
      super(script, LogAnalysisMapperModel.new(key, value))
    end

    include LogAnalysisMapRed

    # model methods
    def_delegators :@model, *AVAILABLE_METHODS
  end

  class LogAnalysisReducer < BaseReducer
    def initialize(script, key, values)
      super(script, LogAnalysisReducerModel.new(key, values))
    end

    include LogAnalysisMapRed

    # model methods
    def_delegators :@model, *AVAILABLE_METHODS
  end

  # model
  class LogAnalysisMapperModel < BaseMapperModel
    def initialize(key, value)
      super(key, value)
      @columns = []
    end

    def column(index, &block)
      @current = @columns[index]
      yield if block_given?
      @current || Column.new(index, nil)
    end

    def separate(sep)
      parts = @value.split(sep)
      @columns = parts.enum_for(:each_with_index).map {|p, i| Column.new(i, p)}
    end

    def pattern(re)
      if @value =~ re
        md = Regexp.last_match
        @columns = md.captures.enum_for(:each_with_index).map {|p, i| Column.new(i, p)}
      end
    end

    def count_uniq
      @controller.emit([PREFIX, @current.index, KEY_SEP, @current.text].join => 1)
    end

    def sum
      @controller.emit([PREFIX, @current.index].join => @current.text.to_i)
    end

    class Column
      attr_reader :index, :text

      def initialize(index, text = nil)
        @index, @text = index, text
      end
    end
  end

  class LogAnalysisReducerModel < BaseReducerModel
    def initialize(key, values)
      super(key, values)

      @columns = []
      if key =~ /#{PREFIX}(\d+)#{KEY_SEP}?(.*)/
        index = $1.to_i
        @columns[index] = Column.new(key, values)
      end
    end

    def column(index, &block)
      @current = @columns[index]
      yield if block_given?
      @current || Column.new(PREFIX + index.to_s, nil)
    end

    def count_uniq
      @controller.emit(@key => sum_values)
    end

    def sum
      @controller.emit(@key => sum_values)
    end

    private

    def sum_values
      @values.inject {|ret, i| ret + i}
    end

    class Column
      attr_reader :key, :values
      
      def initialize(key, values)
        @key, @values = key, values
      end
    end
  end
end
