# frozen_string_literal: true

module RapidTable
  module DSL
    # The Pagination DSL module provides class-level configuration for pagination functionality
    # in RapidTable.
    #
    # @example Basic usage
    #   class MyTable < RapidTable::Base
    #     self.skip_pagination = false
    #     self.per_page = 25
    #     self.available_per_pages = [10, 25, 50, 100]
    #     self.page_param = :p
    #     self.per_page_param = :size
    #   end
    #
    # @example With pagination disabled
    #   class MyTable < RapidTable::Base
    #     self.skip_pagination = true
    #   end
    module Pagination
      # Extends the base class with pagination DSL functionality.
      #
      # @param base [Class] The table class to extend
      def self.extended(base)
        base.class_eval do
          include RapidTable::Pagination
          include InstanceMethods

          class_attribute :skip_pagination, default: false, instance_accessor: false

          class_attribute :page_param, default: :page, instance_accessor: false
          class_attribute :per_page_param, default: :per_page, instance_accessor: false

          class_attribute :per_page, instance_accessor: false
          class_attribute :available_per_pages, instance_accessor: false

          config_class! do
            attr_accessor :skip_pagination
            attr_accessor :per_page
            attr_accessor :available_per_pages
            attr_accessor :page_param
            attr_accessor :per_page_param

            alias_method :skip_pagination?, :skip_pagination
          end

          register_initializer :pagination_dsl, before: :pagination
        end
      end

      # Instance methods for handling pagination DSL initialization.
      module InstanceMethods
        # convert the column and column_group symbols into the actual objects
        # as defined by the class methods.
        def initialize_pagination_dsl(config)
          config.skip_pagination = self.class.skip_pagination if config.skip_pagination.nil?
          config.per_page ||= self.class.per_page
          config.available_per_pages ||= self.class.available_per_pages
          config.page_param ||= self.class.page_param
          config.per_page_param ||= self.class.per_page_param
        end
      end
    end
  end
end
