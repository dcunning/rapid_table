module RapidTable
  module Support
    def self.included(base)
      base.class_eval do
        include ExtendableClass
        include Hotwire
        include Params
        include RegisterProcs
      end
    end

    def record_id(_record)
      raise ExtensionRequiredError
    end
  end
end
