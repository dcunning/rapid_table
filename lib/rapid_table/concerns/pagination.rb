# frozen_string_literal: true

module RapidTable
  # The Pagination module provides functionality for paginating table data in RapidTable.
  # It exposes the following configuration options to RapidTable::Base:
  #
  # @option config skip_pagination [Boolean] Whether to disable pagination entirely
  # @option config per_page [Integer] The number of records to display per page
  # @option config available_per_pages [Array<Integer>] Available per-page options (default: [25, 50, 100])
  # @option config page_param [Symbol] The parameter name for the current page (default: :page)
  # @option config per_page_param [Symbol] The parameter name for records per page (default: :per)
  module Pagination
    extend ActiveSupport::Concern

    included do
      config_class! do
        attr_accessor :skip_pagination
        attr_accessor :per_page
        attr_accessor :available_per_pages
        attr_accessor :page_param
        attr_accessor :per_page_param

        alias_method :skip_pagination?, :skip_pagination
      end

      with_options to: :config do
        delegate :skip_pagination?
        delegate :available_per_pages
        delegate :page_param
        delegate :per_page_param
      end

      register_initializer :pagination
    end

    def per_page
      return @per_page if defined?(@per_page)

      @per_page = per_page_param_value || config.per_page
      @per_page ||= available_per_pages.first unless available_per_pages.include?(@per_page)

      @per_page
    end

    def page
      return @page if defined?(@page)

      @page = page_param_value&.to_i
      @page = 1 if !page || page < 1

      @page
    end

    # Determines if pagination controls should be hidden because there's only one page of results
    # regardless of the per_page setting.
    #
    # @return [Boolean] True if pagination should be hidden, false otherwise
    def only_ever_one_page?
      skip_pagination? || (total_records_count && total_records_count <= available_per_pages.first)
    end

    # Gets the per_page value from the request parameters.
    #
    # @return [Integer, nil] The per_page value from params, or nil if not present
    def per_page_param_value
      params[per_page_param]&.to_i if params[per_page_param].present?
    end

    # Gets the page value from the request parameters.
    #
    # @return [String, nil] The page value from params, or nil if not present
    def page_param_value
      params[page_param] if params[page_param].present?
    end

    # Renders a select dropdown for choosing the number of records per page.
    #
    # @param options [Hash] Additional HTML options for the select tag
    # @return [String] The rendered select tag HTML
    def per_page_select_tag(**options)
      paginated_url = ->(per_page) { table_path(page_param => 1, per_page_param => per_page) }
      choices = available_per_pages.map { |per_page| [per_page, paginated_url.call(per_page)] }

      data = hotwire_data(options, action: stimulus_action("change", "navigateFromSelect"))

      select_tag(
        param_name(per_page_param),
        options_for_select(choices, paginated_url.call(per_page)),
        **options,
        data:,
      )
    end

    # Renders pagination links for navigating between pages.
    #
    # @param current_page [Integer] The current page number (defaults to self.current_page)
    # @param total_pages [Integer] The total number of pages (defaults to self.total_pages)
    # @return [String] The rendered pagination links HTML
    def pagination_links(current_page: self.current_page, total_pages: self.total_pages)
      render RapidTable::Components::PaginationLinks.new(
        current_page,
        total_pages,
        path: ->(page) { table_path(page_param => page) },
        table_name:,
        skip_turbo:,
      )
    end

    # Returns the total number of records. Must be implemented by extensions.
    #
    # @return [Integer] The total number of records
    # @raise [ExtensionRequiredError] If no extension provides this functionality
    def total_records_count
      raise ExtensionRequiredError
    end

    # Returns the total number of pages based on total records and per_page.
    # Must be implemented by extensions.
    #
    # @return [Integer] The total number of pages
    # @raise [ExtensionRequiredError] If no extension provides this functionality
    def total_pages
      raise ExtensionRequiredError
    end

    # Returns the current page number. Must be implemented by extensions.
    #
    # @return [Integer] The current page number
    # @raise [ExtensionRequiredError] If no extension provides this functionality
    def current_page
      raise ExtensionRequiredError
    end

  private

    # Initializes pagination configuration with default values and processes request parameters.
    #
    # @param config [Object] The configuration object containing pagination settings
    # @return [void]
    def initialize_pagination(config)
      config.page_param ||= :page
      config.per_page_param ||= :per
      config.available_per_pages ||= [25, 50, 100]

      register_param_name(page_param, per_page_param)
    end
  end
end
