# frozen_string_literal: true

module RapidTable
  module DSL
    module Pagination
      def self.extended(base)
        base.class_eval do
          include RapidTable::Pagination

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

          # convert the column and column_group symbols into the actual objects
          # as defined by the class methods.
          register_initializer :pagination_dsl, before: :pagination do |table, options|
            config.skip_pagination = table.class.skip_pagination if config.skip_pagination.nil?
            config.per_page ||= table.class.per_page
            config.available_per_pages ||= table.class.available_per_pages
            config.page_param ||= table.class.page_param
            config.per_page_param ||= table.class.per_page_param
          end
        end
      end
    end
  end
end
