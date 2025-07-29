module RapidTable
  module Ext
    module ActiveRecord
      def self.included(base)
        base.class_eval do
          include Search if included_modules.include?(Concerns::Search)
          include Sorting if included_modules.include?(Concerns::Sorting)
        end
      end

      def each_record(batch_size: nil, skip_pagination: false, &block)
        collection = self.records
        collection = collection.unscope(:limit, :offset) if skip_pagination
        collection.find_each(batch_size:, &block)
      end

      def record_id(record)
        record.send(record.class.primary_key)
      end

      # TODO: support NULLS FIRST and NULLS LAST for order
      module Sorting
        def self.included(base)
          base.class_eval do
            register_filter :sorting, unless: :skip_sorting?

            column_class! do
              attr_accessor :nulls_last
              alias_method :nulls_last?, :nulls_last
            end
          end
        end

        def filter_sorting(scope)
          return unless sort_column
          return filter_sorting_nulls_last(scope) if sort_column.nulls_last?

          scope.reorder(nil).order(sort_column.id => sort_order)
        end

        def filter_sorting_nulls_last(scope)
          # be extra careful about SQL injection here even though
          # these values should be coming our code, not the request.
          id = ::ActiveRecord::Base.connection.quote_column_name(sort_column.id)
          raise ArgumentEror unless %w[asc desc].include?(sort_order)

          scope.reorder(nil).order("#{id} #{sort_order} NULLS LAST")
        end
      end

      # register_initializer :search_dsl, before: :search do |table, config|

      module Search
        def self.included(base)
          base.class_eval do
            # only search when the ActiveRecord class has a #search scope
            register_initializer :search_activerecord, after: :search do |table, config|
              base_scope = table.base_scope
              config.skip_search = true unless base_scope.is_a?(::ActiveRecord::Relation) && base_scope.klass.respond_to?(:search)
            end
          end
        end

        def filter_search(scope)
          scope.search(search_query)
        end
      end
    end
  end
end
