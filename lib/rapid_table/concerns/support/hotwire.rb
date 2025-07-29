module RapidTable
  module Support
    module Hotwire
      extend ActiveSupport::Concern

      included do
        attr_accessor :skip_turbo
        alias_method :skip_turbo?, :skip_turbo
      end

      def turbo_stream?
        !skip_turbo?
      end

      # returns nil if turbo_stream? is false
      def turbo_stream
        turbo_stream? || nil
      end

    private

      def stimulus_controller
        @stimulus_controller || "rapid-table"
      end

      def stimulus_controller=(value)
        @stimulus_controller = value
      end

      def stimulus_action(action, js_method)
        "#{action}->#{stimulus_controller}##{js_method}"
      end

      def stimulus_actions(*actions)
        actions.in_groups_of(2).map do |action, js_method|
          stimulus_action(action, js_method)
        end.join(" ")
      end

      def stimulus_target
        "#{stimulus_controller}-target"
      end

      def hotwire_data(options = {}, turbo_stream: self.turbo_stream, **data)
        return data.merge(turbo_stream:) unless options[:data]

        raise NotImplementedError, "#hotwire_data is not implemented" # TODO
      end
    end
  end
end
