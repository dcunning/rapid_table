# frozen_string_literal: true

module RapidTable
  # Class-level DSL for defining tables.
  module DSL
    # Extends the base class with DSL functionality.
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
