module RapidTable
  module Ext
    module Kaminari
      def self.included(base)
        base.class_eval do
          include Pagination if included_modules.include?(Concerns::Pagination)
        end
      end

      module Pagination
        def self.included(base)
          base.class_eval do
            register_filter :pagination, unless: :skip_pagination?

            with_options to: :records do
              delegate :total_pages
              delegate :current_page
            end
          end
        end

        def filter_pagination(scope)
          scope.page(page).per(per_page)
        end

        def total_records_count
          records.total_count
        end
      end
    end
  end
end
