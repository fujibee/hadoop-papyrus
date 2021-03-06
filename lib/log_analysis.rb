require 'hadoop_dsl'
require 'enumerator'

module HadoopDsl::LogAnalysis
  KEY_SEP = "\t"
  PREFIX = 'col'
  PASS = nil
  MODEL_METHODS = [:column, :value]

  # controller
  class LogAnalysisMapper < HadoopDsl::BaseMapper
    @@reg_cache = {}

    def initialize(script, key, value)
      super(script, LogAnalysisMapperModel.new(key, value))
    end

    # model methods
    def_delegators :@model, *MODEL_METHODS
   
    def topic(desc, options = {}, &block)
      @model.create_topic(desc, options)
      yield if block_given?
      current_topic
    end

    def separate(sep)
      parts = case sep
              when Symbol
                case sep
                when :csv
                  require 'csv'
                  CSV.parse(value).flatten
                when :tsv then value.split("\t")
                else raise "no supported separator #{sep}"
                end
              when String then value.split(sep)
              end
      @model.create_or_replace_columns_with(parts) {|column, value| column.value = value}
    end

    def pattern(reg_str)
      # try to get RE from cache
      cached = @@reg_cache[reg_str] 
      re = cached ? @@reg_cache[reg_str] : Regexp.new(reg_str)
      @@reg_cache[reg_str] ||= re # new cache

      if value =~ re
        md = Regexp.last_match
        @model.create_or_replace_columns_with(md.captures) {|column, value| column.value = value}
      else throw :each_line # non-local exit
      end
    end

    # column names by String converted to Symbol
    def column_name(*names)
      sym_names = names.map {|name| name.is_a?(String) ? name.to_sym : name }
      @model.create_or_replace_columns_with(sym_names) {|column, name| column.name = name}
    end

    def group_by(column_or_value)
      case column_or_value
      when LogAnalysisMapperModel::Column
        column = column_or_value
        current_topic.key_elements << column.value
      else
        value = column_or_value
        current_topic.key_elements << value
      end
    end

    def group_date_by(column, term)
      require 'time'
      time = parse_time(column.value)
      time_key = case term
                 when :hour_of_day then time.strftime('%H') 
                 when :daily then time.strftime('%Y%m%d') 
                 when :monthly then time.strftime('%Y%m') 
                 when :yearly then time.strftime('%Y') 
                 end
      current_topic.key_elements << time_key
    end

    # emitters
    def count_uniq(column_or_value)
      uniq_key =
        case column_or_value
        when LogAnalysisMapperModel::Column
          column = column_or_value
          column.value
        else column_or_value # value
        end
      current_topic.key_elements << uniq_key
      emit(current_topic.key => 1)
    end

    def count
      emit(current_topic.key => 1)
    end

    def sum(column)
      emit(current_topic.key => column.value.to_i)
    end

  private
    def current_topic; @model.current_topic end

    def parse_time(str)
      begin Time.parse(str)
      rescue
        # apachelog pattern ex) "10/Oct/2000:13:55:36 -0700"
        Time.parse($1) if str =~ /^(\d*\/\w*\/\d*):/
      end
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
      aggregate_on_topic
    end

    def count
      aggregate_on_topic
    end

    def sum(column)
      aggregate_on_topic
    end

  private
    def aggregate_on_topic
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
      attr_reader :key_elements

      def initialize(desc, label = nil)
        @desc, @label = desc, label
        @key_elements = []
      end

      def label
        @label || @desc.gsub(/\s/, '_')
      end

      def key
        without_label =
          @key_elements.size > 0 ? @key_elements.join(KEY_SEP) : nil
        [label, without_label].compact.join(KEY_SEP)
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
