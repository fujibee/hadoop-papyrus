require 'core'
require 'enumerator'

module HadoopDsl::HiveLike
  include HadoopDsl
  
  AVAILABLE_METHODS = [:select]

  class HiveLikeSetup < BaseSetup
    def load_data(inputs, table)
      @from = inputs
    end
  end

  # common
  module HiveLikeMapRed
    def pre_process(body)
      processed = ""
      body.each do |line|
        next if line =~ /^#/
        if line =~ /^(\w*)\s+(.*);$/
          method = $1
          args = $2.gsub(/[\(\)]/, ' ').split.map do |s|
            stripped = s.gsub(/[\s,]/, '')
            %Q!"#{stripped}"!
          end.join(", ")
          processed << "#{method}(#{args})\n"
        else 
          processed << line + "\n"
        end
      end
      processed
    end
  end

  # controller
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
    def initialize(key, value)
      super(key, value)
    end

    # emitters
    def select(*args)
      from_index = args.index('from')
      if from_index
        @controller.emit(args[from_index + 1] => args[0...from_index].join(", "))
      end
    end
  end

  class HiveLikeReducerModel < BaseReducerModel
    def initialize(key, values)
      super(key, values)
    end

    # emitters
    def select(*args)
      identity
    end
  end
end
