# frozen_string_literal: true

module RapidTable
  module DSL
    def self.extended(base)
      base.class_eval do
        extend BulkActions
        extend Columns
        extend Export
        extend Pagination
        extend Search
        extend Sorting
      end
    end
  end
end
