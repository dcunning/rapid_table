# frozen_string_literal: true

module RapidTable
  module DSL
    module Columns
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

      # HACK: skip_export is from the Export module :(
      def column(id, **options)
        columns_by_id[id] = build_column(**options, id:)
      end

      def column_group(id, column_ids, **options)
        column_groups_by_id[id] = build_column_group(**options, id:, column_ids:)
      end

      def columns
        ((superclass&.columns if superclass.respond_to?(:columns)) || []) +
          columns_by_id.values
      end

      def column_groups
        ((superclass&.column_groups if superclass.respond_to?(:column_groups)) || []) +
          column_groups_by_id.values
      end

      def find_column(column_id)
        columns_by_id[column_id] ||
          (superclass&.find_column(column_id) if superclass.respond_to?(:find_column))
      end

      def find_column!(column_id)
        find_column(column_id) || raise(RapidTable::ColumnNotFoundError, "Column #{column_id} not found")
      end

      def find_column_group(group_id)
        column_groups_by_id[group_id] ||
          (define_default_column_group if group_id == :default) ||
          (superclass.find_column_group(group_id) if superclass.respond_to?(:find_column_group))
      end

      def find_column_group!(group_id)
        find_column_group(group_id) || raise(RapidTable::ColumnGroupNotFoundError, "Column group #{group_id} not found")
      end

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

    private

      def columns_by_id
        @columns_by_id ||= {}
      end

      def column_groups_by_id
        @column_groups_by_id ||= {}
      end

      def define_default_column_group
        column_group(:default, columns.map(&:id))
      end

      module InstanceMethods
      private

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
