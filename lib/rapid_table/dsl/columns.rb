# frozen_string_literal: true

module RapidTable
  module DSL
    # The Columns DSL module provides class-level configuration for column functionality
    # in RapidTable.
    #
    # @example Basic usage
    #   class MyTable < RapidTable::Base
    #     column :id
    #     column :name
    #     column :email
    #     column :created_at
    #
    #     # implied cell method
    #     def email_cell(record)
    #       record.email.downcase
    #     end
    #   end
    #
    # @example With custom labels and cell methods
    #   class MyTable < RapidTable::Base
    #     column :id, label: "ID"
    #     column :name, label: "Full Name"
    #     column :email, cell_method: :formatted_email
    #
    #     # explicitly specified cell method
    #     def formatted_email(record)
    #       record.email.downcase
    #     end
    #   end
    #
    # @example With column groups
    #   class MyTable < RapidTable::Base
    #     column :id
    #     column :name
    #     column :email
    #     column :created_at
    #
    #     # allow rendering this table with a preconfigured subset of columns
    #     column_group :basic, [:name, :email]
    #   end
    module Columns
      # Extends the base class with columns DSL functionality.
      #
      # @param base [Class] The table class to extend
      def self.extended(base)
        base.class_eval do
          include RapidTable::Columns
          include InstanceMethods

          # convert the column and column_group symbols into the actual objects
          # as defined by the class methods.
          register_initializer :columns_dsl, before: :columns

          def_extendable_class :column_group do
            attr_accessor :id
            attr_accessor :column_ids
          end

          config_class! do
            attr_accessor :column_ids
            attr_accessor :column_group_id
          end
        end
      end

      # Defines a new column for this table.
      #
      # @param id [Symbol] The unique identifier for the column
      # @param options [Hash] Additional options for the column (label, cell_method, etc.)
      # @return [Object] The created column object
      # @example
      #   column :id, label: "ID"
      #   column :email, cell_method: :formatted_email
      def column(id, **options)
        columns_by_id[id] = build_column(**options, id:)
      end

      # Defines a new column group for this table.
      #
      # @param id [Symbol] The unique identifier for the column group
      # @param column_ids [Array<Symbol>] The column IDs to include in this group
      # @param options [Hash] Additional options for the column group
      # @return [Object] The created column group object
      # @example
      #   column_group :basic_info, [:id, :name, :email]
      def column_group(id, column_ids, **options)
        column_groups_by_id[id] = build_column_group(**options, id:, column_ids:)
      end

      # Gets all defined columns for this table, including inherited ones.
      #
      # @return [Array<Object>] Array of column objects
      def columns
        ((superclass&.columns if superclass.respond_to?(:columns)) || []) +
          columns_by_id.values
      end

      # Gets all defined column groups for this table, including inherited ones.
      #
      # @return [Array<Object>] Array of column group objects
      def column_groups
        ((superclass&.column_groups if superclass.respond_to?(:column_groups)) || []) +
          column_groups_by_id.values
      end

      # Finds a column by ID, searching up the inheritance chain.
      #
      # @param column_id [Symbol] The ID of the column to find
      # @return [Object, nil] The found column or nil if not found
      def find_column(column_id)
        columns_by_id[column_id] ||
          (superclass&.find_column(column_id) if superclass.respond_to?(:find_column))
      end

      # Finds a column by ID, raising an error if not found.
      #
      # @param column_id [Symbol] The ID of the column to find
      # @return [Object] The found column
      # @raise [RapidTable::ColumnNotFoundError] If the column is not found
      def find_column!(column_id)
        find_column(column_id) || raise(RapidTable::ColumnNotFoundError, "Column #{column_id} not found")
      end

      # Finds a column group by ID, searching up the inheritance chain.
      #
      # @param group_id [Symbol] The ID of the column group to find
      # @return [Object, nil] The found column group or nil if not found
      def find_column_group(group_id)
        column_groups_by_id[group_id] ||
          (define_default_column_group if group_id == :default) ||
          (superclass.find_column_group(group_id) if superclass.respond_to?(:find_column_group))
      end

      # Finds a column group by ID, raising an error if not found.
      #
      # @param group_id [Symbol] The ID of the column group to find
      # @return [Object] The found column group
      # @raise [RapidTable::ColumnGroupNotFoundError] If the column group is not found
      def find_column_group!(group_id)
        find_column_group(group_id) || raise(RapidTable::ColumnGroupNotFoundError, "Column group #{group_id} not found")
      end

      # Finds columns by IDs or column group ID.
      #
      # @param column_ids [Array<Symbol>, nil] The column IDs to find
      # @param column_group_id [Symbol, nil] The column group ID to find columns for
      # @return [Array<Object>] Array of found column objects
      # @raise [ArgumentError] If both column_ids and column_group_id are specified
      # @raise [ArgumentError] If neither column_ids nor column_group_id is specified
      def find_columns!(column_ids: nil, column_group_id: nil)
        raise ArgumentError, "column_ids and column_group_id cannot be used together" if column_ids && column_group_id

        if column_ids
          column_ids.map { |id| find_column!(id) }
        elsif column_group_id
          find_columns!(column_ids: find_column_group!(column_group_id).column_ids)
        else
          raise ArgumentError, "column_ids or column_group_id must be specified"
        end
      end

      # Returns the default column group.
      #
      # @return [Object] The default column group
      def default_column_group
        column_groups_by_id[:default] || define_default_column_group
      end

    private

      # Returns the registry of columns by ID.
      #
      # @return [Hash<Symbol, Object>] The registry of columns
      def columns_by_id
        @columns_by_id ||= {}
      end

      # Returns the registry of column groups by ID.
      #
      # @return [Hash<Symbol, Object>] The registry of column groups
      def column_groups_by_id
        @column_groups_by_id ||= {}
      end

      # Defines the default column group containing all columns.
      #
      # @return [Object] The default column group
      def define_default_column_group
        column_group(:default, columns.map(&:id))
      end

      # Instance methods for handling columns DSL initialization.
      module InstanceMethods
        # Initializes columns DSL configuration from column groups or IDs.
        #
        # @param config [Object] The configuration object
        # @return [void]
        def initialize_columns_dsl(config)
          # if neither are specified, use the default column group
          config.column_group_id = :default if config.column_ids.nil? && config.column_group_id.nil?

          config.columns = self.class.find_columns!(
            column_ids: config.column_ids,
            column_group_id: config.column_group_id,
          )
        end
      end
    end
  end
end
