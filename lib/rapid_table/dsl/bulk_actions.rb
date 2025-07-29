# frozen_string_literal: true

module RapidTable
  module DSL
    # The BulkActions DSL module provides class-level configuration for bulk actions
    # functionality in RapidTable.
    #
    # @example Basic usage
    #   class MyTable < RapidTable::Base
    #     self.skip_bulk_actions = false
    #     self.bulk_actions_param = :selected_ids
    #
    #     bulk_action :delete
    #     bulk_action :archive, label: "Archive Selected"
    #   end
    #
    # @example With bulk actions disabled
    #   class MyTable < RapidTable::Base
    #     self.skip_bulk_actions = true
    #   end
    module BulkActions
      # Extends the base class with bulk actions DSL functionality.
      #
      # @param base [Class] The table class to extend
      def self.extended(base)
        base.class_eval do
          include RapidTable::BulkActions

          class_attribute :skip_bulk_actions, default: false, instance_accessor: false
          class_attribute :bulk_actions_param, default: :ids, instance_accessor: false

          config_class! do
            attr_accessor :skip_bulk_actions
            attr_accessor :bulk_actions_param
            attr_accessor :bulk_action_ids
            attr_accessor :bulk_actions
          end

          # convert the bulk_action symbols into the actual objects
          # as defined by the class methods.
          register_initializer :bulk_actions_dsl, before: :bulk_actions do |table, config|
            config.skip_bulk_actions = table.class.skip_bulk_actions if config.skip_bulk_actions.nil?
            config.bulk_actions_param ||= table.class.bulk_actions_param

            ids = config.bulk_action_ids
            config.bulk_actions ||= ids ? ids.map { |id| table.class.find_bulk_action(id) } : table.class.bulk_actions
          end
        end
      end

      # Defines a new bulk action for this table.
      #
      # @param id [Symbol] The unique identifier for the bulk action
      # @param label [String, nil] The display label for the bulk action (optional)
      # @param options [Hash] Additional options for the bulk action
      # @return [Object] The created bulk action object
      # @example
      #   bulk_action :delete, label: "Delete Selected"
      def bulk_action(id, label: nil, **options)
        bulk_actions_by_id[id] = build_bulk_action(**options, id:, label:)
      end

      # Gets all defined bulk actions for this table.
      #
      # @return [Array<Object>] Array of bulk action objects
      def bulk_actions
        (superclass.respond_to?(:bulk_actions) ? superclass.bulk_actions : []) +
          bulk_actions_by_id.values
      end

      # Finds a bulk action by ID, searching up the inheritance chain.
      #
      # @param id [Symbol] The ID of the bulk action to find
      # @return [Object, nil] The found bulk action or nil if not found
      # @raise [RapidTable::BulkActionNotFoundError] If the bulk action is not found
      def find_bulk_action(id)
        bulk_actions_by_id[id] ||
          (superclass&.find_bulk_action(id) if superclass.respond_to?(:find_bulk_action)) ||
          raise(RapidTable::BulkActionNotFoundError, "Bulk action #{id} not found")
      end

    private

      # Returns the registry of bulk actions by ID.
      #
      # @return [Hash<Symbol, Object>] The registry of bulk actions
      def bulk_actions_by_id
        @bulk_actions_by_id ||= {}
      end
    end
  end
end
