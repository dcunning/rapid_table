module RapidTable
  module Search
    def self.included(base)
      base.class_eval do
        include RapidTable::Support

        config_class! do
          attr_accessor :skip_search
          attr_accessor :search_param

          alias_method :skip_search?, :skip_search
        end

        with_options to: :config do
          delegate :skip_search?
          delegate :search_param
        end

        register_initializer :search
        register_filter :search, unless: :skip_search?
      end
    end

    def initialize_search(config)
      config.search_param ||= :q

      register_param_name(search_param)
    end

    def search_query
      params[search_param]
    end

    def search_field_tag(options = {})
      @template.search_field_tag(
        param_name(search_param),
        search_query,
        id: id_for(:search),
        **options,
        placeholder: t("search.placeholder"),
      )
    end

    def search_field_form(url: url_for(action: action_name), method: :get, **options, &block)
      form_tag(url, method:, **options.merge(data: { turbo_stream: })) do
        search = block_given? ? capture(&block) : search_field_tag
        hidden_fields_for_registered_params(page: 1) << search
      end
    end

    def filter_search(scope)
      raise ExtensionRequiredError, "not implemented"
    end
  end
end
