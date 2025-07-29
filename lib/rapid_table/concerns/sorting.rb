module RapidTable
  module Sorting
    def self.included(base)
      base.class_eval do
        include RapidTable::Columns

        attr_accessor :sort_column

        register_initializer :sorting, after: :columns
        register_filter :sorting, unless: :skip_sorting?

        config_class! do
          attr_accessor :skip_sorting
          attr_accessor :sort_column_param
          attr_accessor :sort_order_param

          attr_accessor :sort_column_id
          attr_accessor :sort_order

          alias_method :skip_sorting?, :skip_sorting
        end

        with_options to: :config do
          delegate :skip_sorting?
          delegate :sort_column_param
          delegate :sort_order_param
          delegate :sort_order
        end

        column_class! do
          attr_accessor :sortable, :sort_order
          alias_method :sortable?, :sortable
        end
      end
    end

    def initialize_sorting(config)
      config.sort_column_param ||= :sort
      config.sort_order_param ||= :dir
      register_param_name(config.sort_column_param, config.sort_order_param)

      sort_column_id = sort_column_param_value || config.sort_column_id
      if sort_column_id.is_a?(Symbol) || sort_column_id.is_a?(String)
        self.sort_column = find_sortable_column(sort_column_id)
      end

      # standardize on strings since we don't want to symbolize param values
      config.sort_order = (sort_order_param_value || sort_order || sort_column&.sort_order)&.to_s || "asc"
    end

    def filter_sorting(scope)
      raise ExtensionRequiredError
    end

    def sort_column_param_value
      value = params[sort_column_param]
      value = nil if value.present? && !find_sortable_column(value)
      value
    end

    def available_sort_orders
      %w[asc desc]
    end

    def reverse_sort_order(order)
      return "asc" if order == "desc"

      "desc"
    end

    def sort_order_param_value
      value = params[sort_order_param]
      value = nil if value.present? && !available_sort_orders.include?(value)
      value
    end

    def column_label(column)
      label = determine_column_label(column)
      return tag.span(label) if skip_sorting? || !column.sortable?

      so = sort_column&.id == column.id ? reverse_sort_order(sort_order) : column.sort_order

      link_to(
        h(label) << sort_order_label(column),
        table_path(sort_column_param => column.id, sort_order_param => so),
        class: "admin-table-header-cell-link",
        data: { turbo_stream: },
      )
    end

    def sort_order_label(column)
      return "" unless column.sortable?

      tag.span(sort_order_icon_label(column), class: "admin-table-header-sort-order")
    end

    def sort_order_icon_label(column)
      return h("") unless column.sortable?

      if sort_column&.id != column.id
        "▲<br/>▼".html_safe
      elsif sort_order == "asc"
        "▲<br/>&nbsp;".html_safe
      else
        "&nbsp;<br/>▼".html_safe
      end
    end

  private

    def find_sortable_column(id)
      columns.find { |column| column.sortable? && column.id.to_s == id.to_s }
    end
  end
end
