module RapidTable
  module Pagination
    # TODO: extract kaminari stuff from the generic pagination stuff
    # TODO: support paginating regular arrays
    def self.included(base)
      base.class_eval do
        include RapidTable::Support

        attr_accessor :page
        attr_accessor :per_page

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
    end

    def initialize_pagination(config)
      config.page_param ||= :page
      config.per_page_param ||= :per

      config.available_per_pages ||= [25, 50, 100]

      self.per_page ||= per_page_param_value
      self.per_page ||= config.available_per_pages.first unless config.available_per_pages.include?(per_page)

      self.page = page_param_value&.to_i
      self.page = 1 if !page || page < 1

      register_param_name(page_param, per_page_param)
    end

    def skip_pagination?
      skip_pagination
    end

    # we have pagination enabled but there will only ever be one page of results
    # so we don't need to show the pagination actions
    def only_ever_one_page?
      skip_pagination? || total_records_count <= available_per_pages.first
    end

    def per_page_param_value
      params[per_page_param]&.to_i if params[per_page_param].present?
    end

    def page_param_value
      params[page_param] if params[page_param].present?
    end

    def per_page_select_tag(**options)
      paginated_url = ->(per_page) { table_path(page_param => 1, per_page_param => per_page) }
      choices = available_per_pages.map { |per_page| [per_page, paginated_url.call(per_page)] }

      select_tag(
        param_name(per_page_param),
        options_for_select(choices, paginated_url.call(per_page)),
        **options,
        data: hotwire_data(options,
                           action: stimulus_action("change", "navigateFromSelect"),
                           turbo_stream:,
                          ),
      )
    end

    def pagination_links(current_page: self.current_page, total_pages: self.total_pages)
      render RapidTable::Components::PaginationLinks.new(
        current_page,
        total_pages,
        path: ->(page) { table_path(page_param => page) },
        table_name:,
        skip_turbo:,
      )
    end

    def total_records_count
      raise ExtensionRequiredError
    end

    def total_pages
      raise ExtensionRequiredError
    end

    def current_page
      raise ExtensionRequiredError
    end
  end
end
