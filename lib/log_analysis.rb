require 'core'
require 'enumerator'

module HadoopDsl::LogAnalysis
  include HadoopDsl
  
  KEY_SEP = "\t"
  PREFIX = 'col'
  PASS = nil
  AVAILABLE_METHODS = [:separate, :pattern, :column_name, :column, :value, :count_uniq, :sum]

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

    def column(key, &block)
      @current = case key
              when Integer then @columns[key]
              when Symbol then (@columns.select {|c| c.name == key}).first
              when String then (@columns.select {|c| c.name == key.to_sym}).first
              end
      yield if block_given?
      @current
    end

    def value; @current.value end

    def separate(sep)
      parts = @value.split(sep)
      @columns = parts.enum_for(:each_with_index).map do |p, i|
        column = @columns[i] ? @columns[i] : Column.new(i)
        column.value = p
        column
      end
    end

    def pattern(re)
      if @value =~ re
        md = Regexp.last_match
        @columns = md.captures.enum_for(:each_with_index).map do |p, i|
        column = @columns[i] ? @columns[i] : Column.new(i)
        column.value = p
        column
        end
      end
    end

    # column names by String converted to Symbol
    def column_name(*names)
      column_names = names.map {|name| name.is_a?(String) ? name.to_sym : name }
      @columns = column_names.enum_for(:each_with_index).map do |p, i|
        column = @columns[i] ? @columns[i] : Column.new(i)
        column.name = p
        column
      end
    end

    # emitters
    def count_uniq
      @controller.emit([PREFIX, @current.index, KEY_SEP, @current.value].join => 1)
    end

    def sum
      @controller.emit([PREFIX, @current.index].join => @current.value.to_i)
    end

    class Column
      attr_reader :index
      attr_accessor :value, :name

      def initialize(index, value = nil)
        @index, @value = index, value
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
