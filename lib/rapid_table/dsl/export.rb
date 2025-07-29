# frozen_string_literal: true

module RapidTable
  module DSL
    # The Export DSL module provides class-level configuration for export functionality
    # in RapidTable.
    #
    # @example Basic usage
    #   class MyTable < RapidTable::Base
    #     self.skip_export = false
    #     self.csv_column_separator = ";"
    #     self.export_batch_size = 500
    #   end
    #
    # @example With export disabled
    #   class MyTable < RapidTable::Base
    #     self.skip_export = true
    #   end
    module Export
      # Extends the base class with export DSL functionality.
      #
      # @param base [Class] The table class to extend
      def self.extended(base)
        base.class_eval do
          include RapidTable::Export

          class_attribute :skip_export, default: false, instance_accessor: false
          class_attribute :csv_column_separator, default: ",", instance_accessor: false
          class_attribute :export_batch_size, default: 1000, instance_accessor: false

          config_class! do
            attr_accessor :skip_export
            attr_accessor :csv_column_separator
            attr_accessor :export_batch_size

            alias_method :skip_export?, :skip_export
          end

          register_initializer :export_dsl, before: :export do |table, config|
            config.skip_export = table.class.skip_export if config.skip_export.nil?
            config.csv_column_separator ||= table.class.csv_column_separator
            config.export_batch_size ||= table.class.export_batch_size
          end
        end
      end
    end
  end
end
