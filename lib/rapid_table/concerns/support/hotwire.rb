# frozen_string_literal: true

module RapidTable
  module Support
    # The Hotwire module provides integration with Hotwire (Turbo and Stimulus) for
    # RapidTable. It handles Turbo Stream responses and generates Stimulus controller
    # actions and targets for interactive table functionality.
    #
    # This module is included by other RapidTable modules to provide Hotwire integration
    # for features like bulk actions, pagination, sorting, and search.
    #
    # @example Basic usage
    #   class MyTable < RapidTable::Base
    #     # Turbo Stream responses are automatically handled
    #     # Stimulus actions are generated for interactive elements
    #   end
    #
    # @example Customizing Stimulus controller
    #   class MyTable < RapidTable::Base
    #     def stimulus_controller
    #       "my-custom-table"
    #     end
    #   end
    module Hotwire
      extend ActiveSupport::Concern

      included do
        attr_accessor :skip_turbo
        alias_method :skip_turbo?, :skip_turbo
      end

      # Checks if Turbo Stream responses should be enabled.
      #
      # @return [Boolean] True if Turbo Stream is enabled, false otherwise
      def turbo_stream?
        !skip_turbo?
      end

      # Returns the Turbo Stream value for data attributes, or nil if disabled.
      #
      # @return [String, nil] The Turbo Stream value or nil if disabled
      def turbo_stream
        turbo_stream? || nil
      end

    private

      # Gets the Stimulus controller name for this table.
      #
      # @return [String] The Stimulus controller name (default: "rapid-table")
      def stimulus_controller
        @stimulus_controller || "rapid-table"
      end

      # Sets the Stimulus controller name for this table.
      #
      # @param value [String] The new Stimulus controller name
      def stimulus_controller=(value)
        @stimulus_controller = value
      end

      # Generates a Stimulus action string in the format "action->controller#method".
      #
      # @param action [String] The DOM event (e.g., "click", "change")
      # @param js_method [String] The JavaScript method to call on the controller
      # @return [String] The formatted Stimulus action string
      def stimulus_action(action, js_method)
        "#{action}->#{stimulus_controller}##{js_method}"
      end

      # Generates multiple Stimulus actions from pairs of action/method arguments.
      #
      # @param actions [Array<String>] Array of action/method pairs
      # @return [String] Space-separated Stimulus action strings
      # @example
      #   stimulus_actions("change", "toggleSelections", "change", "togglePerform")
      #   # => "change->rapid-table#toggleSelections change->rapid-table#togglePerform"
      def stimulus_actions(*actions)
        actions.in_groups_of(2).map do |action, js_method|
          stimulus_action(action, js_method)
        end.join(" ")
      end

      # Generates the Stimulus target attribute name for this table.
      #
      # @return [String] The Stimulus target attribute name
      def stimulus_target
        "#{stimulus_controller}-target"
      end

      # Merges Hotwire data attributes with existing options.
      #
      # @param options [Hash] The existing HTML options
      # @param turbo_stream [String, nil] The Turbo Stream value (defaults to self.turbo_stream)
      # @param data [Hash] Additional data attributes to merge
      # @return [Hash] The merged data attributes
      # @raise [NotImplementedError] If options already contains data attributes (not yet implemented)
      def hotwire_data(options = {}, turbo_stream: self.turbo_stream, **data)
        return data.merge(turbo_stream:) unless options[:data]

        raise NotImplementedError, "#hotwire_data is not implemented" # TODO
      end
    end
  end
end
