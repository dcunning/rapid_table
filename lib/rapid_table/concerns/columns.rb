module RapidTable
  module Columns
    # expose columns and column_group as instance variables.
    def self.included(base)
      base.class_eval do
        include RapidTable::Support

        attr_accessor :columns

        register_initializer :columns

        config_class! do
          include Config
        end

        def_extendable_class :column do
          attr_accessor :id
          attr_accessor :label
          attr_accessor :cell_method

          def cell_method
            @cell_method ||= :"#{id}_cell"
          end
        end
      end
    end

    def initialize_columns(config)
      columns = config.columns || raise(ArgumentError, "columns must be specified")
      columns = self.class.build_columns(columns)
      self.columns = filter_columns(columns)
    end

    def column_label(column)
      tag.span(determine_column_label(column))
    end

    def column_cell(record, column)
      return send(column.cell_method, record) if respond_to?(column.cell_method, true)

      value = record.send(column.id)
      column_type_value(value) || value
    end

  private

    def determine_column_label(column)
      id = column.id
      column.label || RapidTable.t("columns.#{id}", table_name:) || id.to_s.titleize
    end

    def column_type_value(value)
      klass = value.class
      # OPTIMIZE: cache the results so we're not introspecting every time

      helper = :"#{klass.name.underscore.gsub("/", "_")}_cell"
      return unless respond_to?(helper, true)

      send(helper, value)
    end

    def filter_columns(columns)
      except = config.except
      only = config.only

      columns = columns.reject { |column| except.include?(column.id) } if except
      columns = columns.select { |column| only.include?(column.id) } if only
      columns
    end

    module Config
      attr_accessor :columns

      attr_writer :except
      attr_writer :only

      def except
        ensure_array(@except)
      end

      def only
        ensure_array(@only)
      end

    private

      def ensure_array(value)
        value = [value] if value && !value.is_a?(Array)
        value
      end
    end
  end
end
