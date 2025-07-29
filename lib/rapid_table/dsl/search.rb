# frozen_string_literal: true

module RapidTable
  module DSL
    module Search
      def self.extended(base)
        base.class_eval do
          include RapidTable::Search

          class_attribute :skip_search, default: false, instance_accessor: false
          class_attribute :search_param, default: :q, instance_accessor: false

          config_class! do
            attr_accessor :skip_search
            attr_accessor :search_param
          end

          register_initializer :search_dsl, before: :search do |table, config|
            config.skip_search = table.class.skip_search if config.skip_search.nil?
            config.search_param ||= table.class.search_param
          end
        end
      end
    end
  end
end
