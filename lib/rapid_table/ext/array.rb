module RapidTable
  module Ext
    module Array
      def self.included(base)
        base.class_eval do
          include Sorting if included_modules.include?(Concerns::Sorting)
          include Pagination if included_modules.include?(Concerns::Pagination)
        end
      end

      def each_record(batch_size: nil, skip_pagination: false, &block)
        collection = self.records
        collection = collection.unpaginated_array if skip_pagination
        collection.each(&block)
      end

      module Sorting
        def self.included(base)
          base.class_eval do
            register_filter :sorting, unless: :skip_sorting?
          end
        end

        def filter_sorting(scope)
          return unless sort_column

          sorted = scope.sort_by { |record| record.send(sort_column.id) }
          sorted = sorted.reverse if sort_order == "desc"
          sorted
        end
      end

      module Pagination
        def self.included(base)
          base.class_eval do
            register_filter :pagination, unless: :skip_pagination?

            with_options to: :records do
              delegate :current_page
              delegate :total_pages
              delegate :total_records_count
            end
          end
        end

        def filter_pagination(scope)
          page = self.page
          per_page = self.per_page
          start_index = (page - 1) * per_page
          end_index = start_index + per_page - 1

          paginated_array = scope[start_index..end_index] || []

          # TODO: don't do this
          # Extend the array with pagination metadata
          paginated_array.instance_eval do
            @original_array = scope
            @current_page = page
            @per_page = per_page

            def total_pages
              return 0 if @original_array.nil? || @original_array.empty?
              (@original_array.length.to_f / @per_page).ceil
            end

            def current_page
              @current_page
            end

            def total_records_count
              @original_array.length
            end

            def unpaginated_array
              @original_array
            end
          end

          paginated_array
        end
      end
    end
  end
end
