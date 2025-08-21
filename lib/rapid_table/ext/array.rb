# frozen_string_literal: true

module RapidTable
  module Ext
    # RapidTable rendering raw ruby arrays.
    module Array
      extend ActiveSupport::Concern

      included do
        include Pagination if included_modules.include?(RapidTable::Pagination)
        include Sorting if included_modules.include?(RapidTable::Sorting)
        include Search if included_modules.include?(RapidTable::Search)
      end

      # rubocop:disable Lint/UnusedMethodArgument
      def each_record(batch_size: nil, skip_pagination: false, &block)
        collection = records
        collection = collection.unpaginated_array if skip_pagination
        collection.each(&block)
      end
      # rubocop:enable Lint/UnusedMethodArgument

      # RapidTable pagination functionality for raw ruby arrays.
      module Pagination
        extend ActiveSupport::Concern

        included do
          register_filter :pagination, unless: :skip_pagination?

          with_options to: :records do
            delegate :current_page
            delegate :total_pages
            delegate :total_records_count
          end
        end

        def filter_pagination(scope)
          page = self.page
          per_page = self.per_page
          start_index = (page - 1) * per_page
          end_index = start_index + per_page - 1

          paginated_array = scope[start_index..end_index] || []
          PaginatedArray.new(paginated_array, scope, page, per_page)
        end

        # A wrapper around an array that provides pagination metadata.
        class PaginatedArray < ::Array
          def initialize(array, original_array, current_page, per_page)
            super(array)
            @original_array = original_array
            @current_page = current_page
            @per_page = per_page
          end

          def total_pages
            return 0 if @original_array.nil? || @original_array.empty?

            (@original_array.length.to_f / @per_page).ceil
          end

          attr_reader :current_page

          def total_records_count
            @original_array.length
          end

          def unpaginated_array
            @original_array
          end
        end
      end

      # RapidTable searching functionality for raw ruby arrays.
      module Search
        extend ActiveSupport::Concern

        def self.included(base)
          base.class_eval do
            column_class! do
              attr_accessor :searchable
              alias_method :searchable?, :searchable
            end
          end
        end

        def filter_search(scope)
          columns = self.columns.select(&:searchable?)
          return scope if columns.none? || search_query.blank?

          scope.filter do |record|
            columns.any? do |column|
              search_match?(record, column)
            end
          end
        end

        def search_match?(record, column)
          value = record.send(column.id)
          value.to_s.downcase.include?(search_query.downcase) if value && search_query
        end
      end

      # RapidTable sorting functionality for raw ruby arrays.
      module Sorting
        extend ActiveSupport::Concern

        included do
          register_filter :sorting, unless: :skip_sorting?
        end

        def filter_sorting(scope)
          return unless sort_column

          sorted = scope.sort_by { |record| record.send(sort_column.id) }
          sorted = sorted.reverse if sort_order == "desc"
          sorted
        end
      end
    end
  end
end
