# frozen_string_literal: true

module RapidTable
  module Support
    # The Params module helps tables access the request params and maintain state across requests.
    module Params
      extend ActiveSupport::Concern

      included do
        include RegisterProcs

        attr_writer :param_name
        attr_accessor :full_params

        # the action in which the table appears by default (not in response to a POST action)
        attr_accessor :action_name

        register_initializer :params

        config_class! do
          attr_accessor :params
          attr_accessor :param_name
          attr_accessor :action
        end
      end

      # Gets the parameters for this table, handling nested parameter names.
      #
      # @return [Hash, ActionController::Parameters] The parameters for this table
      def params
        (@param_name ? full_params[@param_name] : full_params) || {}
      end

      # Generates a unique ID for form elements, optionally prefixed with the table's param name.
      #
      # @param name [String, Symbol] The base name for the ID
      # @return [String] The generated ID
      # @example
      #   id_for(:search) # => "search" or "table_search" if param_name is "table"
      def id_for(name)
        if @param_name
          "#{@param_name}_#{name}"
        else
          name
        end
      end

      # Generates a parameter name, optionally nested under the table's param name.
      #
      # @param nested_name [String, Symbol, nil] The nested parameter name (optional)
      # @return [String] The generated parameter name
      # @example
      #   param_name(:page) # => "page" or "table[page]" if param_name is "table"
      #   param_name        # => nil or "table" if param_name is "table"
      def param_name(nested_name = nil)
        if nested_name && @param_name
          "#{@param_name}[#{nested_name}]"
        elsif nested_name
          nested_name
        else
          @param_name
        end
      end

      # Gets the list of parameter names that have been registered for this table.
      #
      # @return [Array<String>] The registered parameter names
      def registered_param_names
        @registered_param_names ||= []
      end

      # Registers parameter names that should be preserved across requests.
      #
      # @param param_names [Array<String, Symbol>] The parameter names to register
      # @return [void]
      # @example
      #   register_param_name(:page, :sort, :per_page)
      def register_param_name(*param_names)
        @registered_param_names ||= []
        @registered_param_names += param_names
      end

      # Gets the registered parameters with optional overrides.
      #
      # @param param_overrides [Hash] Optional parameter overrides
      # @return [Hash] The registered parameters with any overrides applied
      # @example
      #   registered_params(page: 2, sort: "name")
      def registered_params(**param_overrides)
        if param_overrides.any?
          registered_params.merge(param_overrides)
        elsif params.is_a?(ActionController::Parameters)
          params.to_unsafe_h.slice(*registered_param_names)
        else
          params.slice(*registered_param_names)
        end
      end

      # Generates hidden form fields for all registered parameters.
      #
      # @param overrides [Hash] Optional parameter overrides
      # @return [String] HTML string containing hidden input fields
      # @example
      #   hidden_fields_for_registered_params(page: 2)
      #   # => '<input type="hidden" name="table[page]" value="2" />...'
      def hidden_fields_for_registered_params(**overrides)
        registered_params(**overrides).map do |name, value|
          hidden_field_tag(param_name(name), value)
        end.join.html_safe
      end

    private

      def initialize_params(config)
        self.param_name = config.param_name
        self.full_params = config.params || {}
        self.action_name = config.action || full_params[:action]
      end
    end
  end
end
