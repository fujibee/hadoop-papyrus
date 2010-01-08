require 'hadoop-dsl'
require 'enumerator'

module HadoopDsl::LogAnalysis
  KEY_SEP = "\t"
  PREFIX = 'col'
  PASS = nil
  MODEL_METHODS = [:column, :value]

  # controller
  class LogAnalysisMapper < HadoopDsl::BaseMapper
    def initialize(script, key, value)
      super(script, LogAnalysisMapperModel.new(key, value))
    end

    # model methods
    def_delegators :@model, *MODEL_METHODS
   
    def topic(desc, options = {}, &block)
      @model.create_topic(desc, options)
      yield if block_given?
      @model.current_topic
    end

    def separate(sep)
      parts = @model.value.split(sep)
      @model.create_or_replace_columns_with(parts) {|column, value| column.value = value}
    end

    def pattern(re)
      if @model.value =~ re
        md = Regexp.last_match
        @model.create_or_replace_columns_with(md.captures) {|column, value| column.value = value}
      end
    end

    # column names by String converted to Symbol
    def column_name(*names)
      sym_names = names.map {|name| name.is_a?(String) ? name.to_sym : name }
      @model.create_or_replace_columns_with(sym_names) {|column, name| column.name = name}
    end

    # emitters
    def count_uniq(column)
      emit([@model.current_topic.label, KEY_SEP, column.value].join => 1)
    end

    def sum(column)
      emit([@model.current_topic.label].join => column.value.to_i)
    end
  end

  class LogAnalysisReducer < HadoopDsl::BaseReducer
    def initialize(script, key, values)
      super(script, LogAnalysisReducerModel.new(key, values))
    end

    # model methods
    def_delegators :@model, *MODEL_METHODS

    def topic(desc, options = {}, &block)
      @model.create_topic(desc, options)
      yield if block_given?
      @model.current_topic
    end

    def count_uniq(column)
      aggregate if @model.topic == @model.current_topic
    end

    def sum(column)
      aggregate if @model.topic == @model.current_topic
    end
  end

  # model
  class LogAnalysisMapperModel < HadoopDsl::BaseMapperModel
    attr_reader :current_topic

    def initialize(key, value)
      super(key, value)
      @columns = ColumnArray.new
      @topics = []
    end

    def column; @columns end

    def create_topic(desc, options)
      @topics << @current_topic = Topic.new(desc, options[:label])
    end

    def create_or_replace_columns_with(array, &block)
      columns = array.enum_for(:each_with_index).map do |p, i|
        c = @columns[i] ? @columns[i] : Column.new(i)
        yield c, p
        c
      end
      @columns = ColumnArray.new(columns)
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

  class LogAnalysisReducerModel < HadoopDsl::BaseReducerModel
    attr_reader :topic, :current_topic

    def initialize(key, values)
      super(key, values)
      if key =~ /(\w*)#{KEY_SEP}?(.*)/
        @topic = Topic.new($1, values)
      end
    end

    def create_topic(desc, options)
      @current_topic = Topic.new(options[:label] || desc.gsub(/\s/, '_'), nil)
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
