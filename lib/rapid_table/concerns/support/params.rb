module RapidTable
  module Support
    module Params
      def self.included(base)
        base.class_eval do
          attr_writer :param_name
          attr_accessor :full_params
        end
      end

      def params
        (@param_name ? full_params[@param_name] : full_params) || {}
      end

      def id_for(name)
        if @param_name
          "#{@param_name}_#{name}"
        else
          name
        end
      end

      def param_name(nested_name = nil)
        if nested_name && @param_name
          "#{@param_name}[#{nested_name}]"
        elsif nested_name
          nested_name
        else
          @param_name
        end
      end

      def registered_param_names
        @registered_param_names ||= []
      end

      def register_param_name(*param_names)
        @registered_param_names ||= []
        @registered_param_names += param_names
      end

      def registered_params(**param_overrides)
        if param_overrides.any?
          registered_params.merge(param_overrides)
        elsif params.is_a?(ActionController::Parameters)
          params.to_unsafe_h.slice(*registered_param_names)
        else
          params.slice(*registered_param_names)
        end
      end

      def hidden_fields_for_registered_params(**overrides)
        registered_params(**overrides).map do |name, value|
          hidden_field_tag(param_name(name), value)
        end.join.html_safe
      end
    end
  end
end
