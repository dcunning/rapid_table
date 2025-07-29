# frozen_string_literal: true

module RapidTable
  module DSL
    # The Sorting DSL module provides class-level configuration for sorting functionality
    # in RapidTable.
    #
    # @example Basic usage
    #   class MyTable < RapidTable::Base
    #     self.skip_sorting = false
    #     self.sort_column = :name
    #     self.sort_order = :asc
    #   end
    #
    # @example With sorting disabled
    #   class MyTable < RapidTable::Base
    #     self.skip_sorting = true
    #   end
    module Sorting
      # Extends the base class with sorting DSL functionality.
      #
      # @param base [Class] The table class to extend
      def self.extended(base)
        base.class_eval do
          extend Columns

          include RapidTable::Sorting
          include InstanceMethods

          class_attribute :skip_sorting, default: false, instance_accessor: false

          register_initializer :sorting_dsl, after: :columns_dsl

          column_group_class! do
            attr_accessor :sort_column, :sort_order
          end
        end
      end

      # Gets the default sort column for this table.
      #
      # @return [Symbol, nil] The sort column ID or nil if not set
      def sort_column
        default_column_group.sort_column
      end

      # Sets the default sort column for this table.
      #
      # @param id [Symbol] The column ID to sort by
      # @return [Object] The modified column group
      def sort_column=(id)
        default_column_group.tap do |group|
          group.sort_column = id
        end
      end

      # Gets the default sort order for this table.
      #
      # @return [String, nil] The sort order ("asc" or "desc") or nil if not set
      def sort_order
        default_column_group.sort_order
      end

      # Sets the default sort order for this table.
      #
      # @param order [String] The sort order ("asc" or "desc")
      # @return [Object] The modified column group
      def sort_order=(order)
        default_column_group.tap do |group|
          group.sort_order = order
        end
      end

      # Instance methods for handling sorting DSL initialization.
      module InstanceMethods
        # Initializes sorting DSL configuration from column groups.
        #
        # @param config [Object] The configuration object
        # @return [void]
        def initialize_sorting_dsl(config)
          config.skip_sorting = self.class.skip_sorting if config.skip_sorting.nil?

          column_group_id = config.column_group_id
          column_group = self.class.find_column_group!(column_group_id) if column_group_id
          return unless column_group

          config.sort_column ||= column_group.sort_column
          config.sort_order ||= column_group.sort_order
        end
      end
    end
  end
end
