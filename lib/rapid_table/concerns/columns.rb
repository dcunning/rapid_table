# frozen_string_literal: true

module RapidTable
  # The Columns module provides functionality for defining and managing table columns
  # in RapidTable. It exposes the following configuration options to RapidTable::Base:
  #
  # @option config columns [Array<Hash, Column>] The columns to display in the table.
  #   Can be specified as:
  #   - Hashes: columns [{id: :name, label: "Full Name"}, {id: :email, cell_method: :formatted_email}]
  #   - Column objects: columns [column1, column2]
  # @option config except [Array, Symbol] Column IDs to exclude from the table
  # @option config only [Array, Symbol] Column IDs to include in the table
  #
  # When using hashes, each hash supports:
  # @option config column.id [Symbol] The column identifier
  # @option config column.label [String] The column label (optional)
  # @option config column.cell_method [Symbol] The method to call for cell rendering (optional)
  module Columns
    extend ActiveSupport::Concern

    included do
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

    # Renders the label for a given column.
    #
    # @param column [Object] The column object containing id and label information
    # @return [String] The rendered HTML span element containing the column label
    def column_label(column)
      tag.span(determine_column_label(column))
    end

    # Renders the cell content for a given record and column.
    #
    # @param record [Object] The record object to render the cell for
    # @param column [Object] The column object defining how to render the cell
    # @return [String] The rendered cell content
    def column_cell(record, column)
      return send(column.cell_method, record) if respond_to?(column.cell_method, true)

      value = record.send(column.id)
      column_type_value(value) || value
    end

  private

    # Initializes the columns configuration from the provided config object.
    #
    # @param config [Object] The configuration object containing column definitions
    # @raise [ArgumentError] If no columns are specified in the configuration
    # @return [void]
    def initialize_columns(config)
      columns = config.columns || raise(ArgumentError, "columns must be specified")
      columns = self.class.build_columns(columns)
      self.columns = filter_columns(columns)
    end

    # Determines the appropriate label for a column.
    #
    # @param column [Object] The column object
    # @return [String] The column label
    def determine_column_label(column)
      id = column.id
      column.label || RapidTable.t("columns.#{id}", table_name:) || id.to_s.titleize
    end

    # Attempts to find a type-specific cell helper method for the given value.
    #
    # @param value [Object] The value to render
    # @return [String, nil] The rendered value or nil if no helper method exists
    def column_type_value(value)
      klass = value.class
      # OPTIMIZE: cache the results so we're not introspecting every time

      helper = :"#{klass.name.underscore.gsub("/", "_")}_cell"
      return unless respond_to?(helper, true)

      send(helper, value)
    end

    # Filters columns based on the only and except configuration options.
    #
    # @param columns [Array] The array of columns to filter
    # @return [Array] The filtered array of columns
    def filter_columns(columns)
      except = config.except
      only = config.only

      columns = columns.reject { |column| except.include?(column.id) } if except
      columns = columns.select { |column| only.include?(column.id) } if only
      columns
    end

    # Extension to the table's configuration class.
    module Config
      attr_accessor :columns
      attr_writer :except
      attr_writer :only

      # Returns the except configuration as an array.
      #
      # @return [Array] The array of column IDs to exclude
      def except
        ensure_array(@except)
      end

      # Returns the only configuration as an array.
      #
      # @return [Array] The array of column IDs to include
      def only
        ensure_array(@only)
      end

    private

      # Ensures a value is returned as an array.
      #
      # @param value [Object] The value to convert to an array
      # @return [Array] The value as an array
      def ensure_array(value)
        value = [value] if value && !value.is_a?(Array)
        value
      end
    end
  end
end
