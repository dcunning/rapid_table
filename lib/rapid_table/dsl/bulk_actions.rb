# frozen_string_literal: true

module RapidTable
  module DSL
    module BulkActions
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

      def bulk_action(id, label: nil, **options)
        bulk_actions_by_id[id] = build_bulk_action(**options, id:, label:)
      end

      def bulk_actions
        bulk_actions_by_id.values
      end

      def find_bulk_action(id)
        bulk_actions_by_id[id] ||
          (superclass&.find_bulk_action(id) if superclass.respond_to?(:find_bulk_action)) ||
          raise(RapidTable::BulkActionNotFoundError, "Bulk action #{id} not found")
      end

    private

      def bulk_actions_by_id
        @bulk_actions_by_id ||= {}
      end
    end
  end
end
