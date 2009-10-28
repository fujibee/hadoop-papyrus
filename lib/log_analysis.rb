require 'core'
require 'enumerator'

module HadoopDsl::LogAnalysis
  include HadoopDsl
  
  KEY_SEP = "\t"
  PREFIX = 'col'

  # controller
  class LogAnalysisMapper < BaseMapper
    def initialize(script, key, value)
      super(script, LogAnalysisMapperModel.new(key, value))
    end
    
    # model keywords
    def data; @model end
    def column; @model.column end
  end

  class LogAnalysisReducer < BaseReducer
    def initialize(script, key, values)
      super(script, LogAnalysisReducerModel.new(key, values))
    end

    # model keywords
    def data; @model end
    def column; @model.column end
  end

  # model
  class LogAnalysisMapperModel < BaseMapperModel
    attr_reader :column

    def initialize(key, value)
      super(key, value)
      @column = []
    end

    def separate(sep)
      parts = @value.split(sep)
      @column = parts.enum_for(:each_with_index).map {|p, i| Column.new(self, i, p)}
    end

    def pattern(re)
      if @value =~ re
        md = Regexp.last_match
        @column = md.captures.enum_for(:each_with_index).map {|p, i| Column.new(self, i, p)}
      end
    end

    class Column
      def initialize(parent, index, text = nil)
        @parent, @index, @text = parent, index, text
      end

      def count_uniq
        @parent.controller.emit([PREFIX, @index, KEY_SEP, @text].join => 1)
      end

      def sum
        @parent.controller.emit([PREFIX, @index].join => @text.to_i)
      end
    end
  end

  class LogAnalysisReducerModel < BaseReducerModel
    attr_reader :column

    def initialize(key, values)
      super(key, values)

      @column = ColumnArray.new(self)
      if key =~ /#{PREFIX}(\d+)#{KEY_SEP}?(.*)/
        index = $1.to_i
        @column[index] = Column.new(self, key, values)
      end
    end

    class ColumnArray < ::Array
      def initialize(parent)
        super()
        @parent = parent
      end

      def [](index)
        at(index) ? at(index) : @parent
      end
    end

    class Column
      def initialize(parent, key, values)
        @parent, @key, @values = parent, key, values
      end

      def count_uniq
        @parent.controller.emit(@key => sum_values)
      end

      def sum
        @parent.controller.emit(@key => sum_values)
      end

      private

      def sum_values
        @values.inject {|ret, i| ret + i}
      end
    end
  end
end
