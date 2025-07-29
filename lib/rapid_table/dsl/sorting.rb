# frozen_string_literal: true

module RapidTable
  module DSL
    module Sorting
      def self.extended(base)
        base.class_eval do
          extend Columns

          include RapidTable::Sorting
          include InstanceMethods

          class_attribute :skip_sorting, default: false, instance_accessor: false

          register_initializer :sorting_dsl, after: :columns_dsl

          config_class! do
            attr_accessor :sort_column_id
          end

          column_group_class! do
            attr_accessor :sort_column_id, :sort_order
          end
        end
      end

      def sort_column
        define_default_column_group.sort_column_id
      end

      def sort_column=(id)
        define_default_column_group.tap do |group|
          group.sort_column_id = id
        end
      end

      def sort_order
        define_default_column_group.sort_order
      end

      def sort_order=(order)
        define_default_column_group.tap do |group|
          group.sort_order = order
        end
      end

      module InstanceMethods
        def initialize_sorting_dsl(config)
          config.skip_sorting = self.class.skip_sorting if config.skip_sorting.nil?

          column_group_id = config.column_group_id
          column_group = self.class.find_column_group!(column_group_id) if column_group_id
          return unless column_group

          config.sort_column_id ||= column_group.sort_column_id
          config.sort_order ||= column_group.sort_order
        end
      end
    end
  end
end
