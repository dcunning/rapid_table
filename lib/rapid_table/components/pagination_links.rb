# frozen_string_literal: true

require "view_component"

module RapidTable
  module Components
    # The PaginationLinks component renders pagination links for a table.
    class PaginationLinks < ViewComponent::Base
      include RapidTable::Support::Hotwire

      attr_reader :current_page
      attr_reader :total_pages
      attr_reader :siblings_count

      attr_accessor :skip_turbo

      # rubocop:disable Metrics/ParameterLists
      def initialize(current_page, total_pages, path:, table_name: nil, skip_turbo: false, siblings_count: 4, **options)
        super()

        @current_page = current_page
        @total_pages = total_pages

        @path = path
        @table_name = table_name
        @siblings_count = siblings_count

        @options = options

        self.skip_turbo = skip_turbo
      end
      # rubocop:enable Metrics/ParameterLists

      def render?
        @total_pages.nil? || @total_pages > 1
      end

      def call
        content_tag(:nav, class: "pagination", role: "navigation", "aria-label": "pager", **@options) do
          safe_join([
            first_link(current_page),
            prev_link(current_page),
            *generate_page_links(current_page, total_pages),
            next_link(current_page, total_pages),
            last_link(current_page, total_pages)
          ].compact,
                   )
        end
      end

      def page_path(page)
        @path.call(page)
      end

      def t(key)
        RapidTable.t("pagination.#{key}", table_name: @table_name)
      end

      def pagination_link_to(text, url, options = {})
        link_to(text, url, options.merge(data: { turbo_stream: }))
      end

      def first_link(current_page)
        return nil if current_page <= 1

        tag.span(class: "first") do
          pagination_link_to(t(:first), page_path(1))
        end
      end

      def prev_link(current_page)
        return nil if current_page <= 1

        tag.span(class: "prev") do
          pagination_link_to(t(:prev), page_path(current_page - 1), rel: "prev")
        end
      end

      def next_link(current_page, total_pages)
        return nil if total_pages && current_page >= total_pages

        tag.span(class: "next") do
          pagination_link_to(t(:next), page_path(current_page + 1), rel: "next")
        end
      end

      def last_link(current_page, total_pages)
        return nil if total_pages.nil? || current_page >= total_pages

        tag.span(class: "last") do
          pagination_link_to(t(:last), page_path(total_pages))
        end
      end

      def generate_page_links(current_page, total_pages)
        links = []

        # Calculate range of pages to show
        start_page, end_page = calculate_page_range(current_page, total_pages)

        # Add gap before if needed
        links << tag.span(t(:gap), class: "page gap") if gaps? && start_page > 1

        # Add page numbers
        (start_page..end_page).each do |page|
          links << generate_page_link(page, current_page)
        end

        # Add gap after if needed
        links << tag.span(t(:gap), class: "page gap") if gaps? && total_pages && end_page < total_pages

        links
      end

      def generate_page_link(page, current_page)
        if page == current_page
          tag.span(page, class: "page current")
        else
          tag.span(class: "page") do
            pagination_link_to(page, page_path(page))
          end
        end
      end

      def gaps?
        siblings_count.positive?
      end

      def calculate_page_range(current_page, total_pages)
        start_page = [current_page - siblings_count, 1].max
        end_page = [current_page + siblings_count, total_pages || Float::INFINITY].min

        # Adjust if we're near the beginning or end
        if start_page == 1
          end_page = [current_page + siblings_count, total_pages || Float::INFINITY].min
        elsif total_pages && end_page == total_pages
          start_page = [current_page - siblings_count, 1].max
        end

        [start_page, end_page]
      end
    end
  end
end
