require 'core'
require 'enumerator'

module HadoopDsl::HiveLike
  include HadoopDsl
  
  AVAILABLE_METHODS = [:select, :create_table, :table]

  # common
  module HiveLikeMapRed
    def pre_process(body)
      processed = ""
      body.each do |line|
        next if line =~ /^#/
        if line =~ /^(\w*)\s+(.*);$/
          method = $1
          args = sprit_and_marge_args($2)
          processed << "#{method}(#{args})\n"
        else 
          processed << line + "\n"
        end
      end
      processed
    end

    def sprit_and_marge_args(raw)
      raw.gsub(/[\(\)]/, ' ').split.map do |s|
        stripped = s.gsub(/[\s,"']/, '')
        %Q!"#{stripped}"!
      end.join(", ")
    end
  end

  # controller
  class HiveLikeSetup < BaseSetup
    def load_data(inputs, table)
      @from = inputs
      @to = inputs.gsub(/#{File.basename(inputs)}$/, 'outputs')
    end
    
    def output_format
      @conf.output_key_class = Text
      @conf.output_value_class = Text
    end

    # might not need but occur error if not exists
    def select(*args) end

    include HiveLikeMapRed
  end

  class HiveLikeMapper < BaseMapper
    def initialize(script, key, value)
      super(script, HiveLikeMapperModel.new(key, value))
    end

    include HiveLikeMapRed

    # model methods
    def_delegators :@model, *AVAILABLE_METHODS
  end

  class HiveLikeReducer < BaseReducer
    def initialize(script, key, values)
      super(script, HiveLikeReducerModel.new(key, values))
    end

    include HiveLikeMapRed

    # model methods
    def_delegators :@model, *AVAILABLE_METHODS
  end

  # model
  class HiveLikeMapperModel < BaseMapperModel
    attr_reader :table

    def initialize(key, value)
      super(key, value)
    end

    # emitters
    def create_table(name, *column_and_type)
      @table = Table.new(name)
      column_and_type.each_with_index do |column, index|
        next if index % 2 != 0 # type
        @table.columns << column_and_type[index]
      end
    end

    def select(*args)
      from_index = args.index('from')
      if from_index
        values = args[0...from_index].map do |column|
          splitted = @value.split(/[,\s]+/)
          splitted[@table.columns.index(column)]
        end
        @controller.emit(args[from_index + 1] => values.join(", "))
      end
    end

    class Table
      attr_reader :name, :columns

      def initialize(name)
        @name = name
        @columns = []
      end

      def column(index) @columns[index] end
    end
  end

  class HiveLikeReducerModel < BaseReducerModel
    def initialize(key, values)
      super(key, values)
    end

    # emitters
    def select(*args) identity end
  end
end
