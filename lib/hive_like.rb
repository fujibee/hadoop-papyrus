require 'hadoop_dsl'

module HadoopDsl::HiveLike
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
          processed << line + "\n" if line
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
  class HiveLikeSetup < HadoopDsl::BaseSetup
    def load_data(inputs, table)
      @from = inputs
      @to = inputs.gsub(/#{File.basename(inputs)}$/, 'outputs')
    end
    
    def output_format
      @conf.output_key_class = HadoopDsl::Text
      @conf.output_value_class = HadoopDsl::Text
    end

    # might not need but occur error if not exists
    def select(*args) end

    include HiveLikeMapRed
  end

  class HiveLikeMapper < HadoopDsl::BaseMapper
    def initialize(script, key, value)
      super(script, HiveLikeMapperModel.new(key, value))
    end

    include HiveLikeMapRed

    def_delegators :@model, :create_table, :table

    # emitters
    def select(*args)
      from_index = args.index('from')
      if from_index
        values = args[0...from_index].map do |column|
          splitted = @model.value.split(/[,\s]+/)
          splitted[@model.table.columns.index(column)]
        end
        emit(args[from_index + 1] => values.join(", "))
      end
    end
  end

  class HiveLikeReducer < HadoopDsl::BaseReducer
    def initialize(script, key, values)
      super(script, HiveLikeReducerModel.new(key, values))
    end

    include HiveLikeMapRed

    # emitters
    def select(*args) identity end
  end

  # model
  class HiveLikeMapperModel < HadoopDsl::BaseMapperModel
    attr_reader :table

    def create_table(name, *column_and_type)
      @table = Table.new(name)
      column_and_type.each_with_index do |column, index|
        next if index % 2 != 0 # type
        @table.columns << column_and_type[index]
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

  class HiveLikeReducerModel < HadoopDsl::BaseReducerModel
  end
end
