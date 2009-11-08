require 'core'
require 'enumerator'

module HadoopDsl::LogAnalysis
  include HadoopDsl
  
  KEY_SEP = "\t"
  PREFIX = 'col'
  PASS = nil
  AVAILABLE_METHODS = [:separate, :pattern, :column_name, :column, :topic, :value, :count_uniq, :sum]

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
      @columns = ColumnArray.new
      @topics = []
    end

    def column; @columns end

    def topic(desc, options = {}, &block)
      @topics << @current_topic = Topic.new(desc, options[:label])
      yield if block_given?
      @current_topic
    end

    def separate(sep)
      parts = @value.split(sep)
      create_or_replace_columns_with(parts) {|column, value| column.value = value}
    end

    def pattern(re)
      if @value =~ re
        md = Regexp.last_match
        create_or_replace_columns_with(md.captures) {|column, value| column.value = value}
      end
    end

    # column names by String converted to Symbol
    def column_name(*names)
      sym_names = names.map {|name| name.is_a?(String) ? name.to_sym : name }
      create_or_replace_columns_with(sym_names) {|column, name| column.name = name}
    end

    def create_or_replace_columns_with(array, &block)
      columns = array.enum_for(:each_with_index).map do |p, i|
        c = @columns[i] ? @columns[i] : Column.new(i)
        yield c, p
        c
      end
      @columns = ColumnArray.new(columns)
    end

    # emitters
    def count_uniq(column)
      @controller.emit([@current_topic.label, KEY_SEP, column.value].join => 1)
    end

    def sum(column)
      @controller.emit([@current_topic.label].join => column.value.to_i)
    end

    class ColumnArray < Array
      def [](key)
        case key
        when Integer then at(key)
        when Symbol then (select {|c| c.name == key}).first
        when String then (select {|c| c.name == key.to_sym}).first
        end
      end
    end

    class Column
      attr_reader :index
      attr_accessor :value, :name

      def initialize(index, value = nil)
        @index, @value = index, value
      end
    end

    class Topic
      def initialize(desc, label = nil)
        @desc, @label = desc, label
      end

      def label
        @label || @desc.gsub(/\s/, '_')
      end
    end
  end

  class LogAnalysisReducerModel < BaseReducerModel
    def initialize(key, values)
      super(key, values)
      if key =~ /(\w*)#{KEY_SEP}?(.*)/
        @topic = Topic.new($1, values)
      end
    end

    def topic(desc, options = {}, &block)
      @current_topic = Topic.new(options[:label] || desc.gsub(/\s/, '_'), nil)
      yield if block_given?
      @current_topic
    end

    def count_uniq(column)
      @controller.emit(@key => sum_values) if @topic == @current_topic
    end

    def sum(column)
      @controller.emit(@key => sum_values) if @topic == @current_topic
    end

    private

    def sum_values
      @values.inject {|ret, i| ret + i}
    end

    class Topic
      attr_reader :label, :values
      
      def initialize(label, values)
        @label, @values = label, values
      end

      def ==(rh) self.label == rh.label end
    end
  end
end
