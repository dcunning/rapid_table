module RapidTable
  # The Support module provides a framework for the core functionality of RapidTable.
  module Support
    extend ActiveSupport::Concern

    included do
      include ExtendableClass
      include Hotwire
      include Params
      include RegisterProcs
    end
  end
end
