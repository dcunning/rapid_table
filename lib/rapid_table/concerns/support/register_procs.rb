# frozen_string_literal: true

module RapidTable
  module Support
    # The RegisterProcs module helps tables register and apply initialization and filter procs.
    # It provides a framework for defining and managing initialization and filter blocks
    # that can be applied to tables in a decentralized-pluginable way.
    module RegisterProcs
      extend ActiveSupport::Concern

      included do
        extend ClassMethods
        include ExtendableClass

        attr_accessor :initializer_procs
        attr_accessor :filter_procs

        attr_accessor :config

        def_extendable_class :config
      end

    private

      def apply_initializers(options)
        self.config = self.class.build_config(options)

        self.class.initializer_procs.each do |initializer_proc|
          apply_proc(:initialize, initializer_proc, config)
        end
      end

      def apply_filters(scope)
        # support delayed execution via procs in case we end up not needing the data.
        scope = scope.call if scope.is_a?(Proc)

        self.class.filter_procs.inject(scope) do |scope, filter_proc|
          apply_proc(:filter, filter_proc, scope) || scope
        end
      end

      def apply_proc(id, proc, *args)
        if_method = proc[2][:if]
        unless_method = proc[2][:unless]
        return if (if_method && !send(if_method)) || (unless_method && send(unless_method))

        if proc[1]
          proc[1].call(self, *args)
        else
          send(:"#{id}_#{proc[0]}", *args)
        end
      end

      # Class methods for registering initialization and filter procs.
      module ClassMethods
        def initializer_procs
          @initializer_procs ||= superclass.respond_to?(:initializer_procs) ? superclass.initializer_procs.dup : []
        end

        def filter_procs
          @filter_procs ||= superclass.respond_to?(:filter_procs) ? superclass.filter_procs.dup : []
        end

        def register_initializer(id, after: nil, before: nil, &block)
          add_proc(initializer_procs, id, block, after:, before:)
        end

        def register_filter(id, after: nil, before: nil, unless: nil, if: nil, &block)
          add_proc(filter_procs, id, block, after:, before:, unless:, if:)
        end

      private

        # rubocop:disable Metrics/ParameterLists
        def add_proc(procs, id, block, after: nil, before: nil, **options)
          existing_index = find_proc_index(procs, id)

          # we're moving the proc to a new spot in the array
          procs.delete_at(existing_index) if existing_index && (after || before)

          element = [id, block, options]

          if after
            procs.insert(find_proc_index!(procs, after) + 1, element)
          elsif before
            procs.insert(find_proc_index!(procs, before), element)
          elsif existing_index
            # replace the existing proc in the same spot in the array
            procs[existing_index] = element
          else
            procs << element
          end
        end
        # rubocop:enable Metrics/ParameterLists

        def find_proc_index!(procs, id)
          find_proc_index(procs, id) || raise(ArgumentError, "Unknown proc: #{id.inspect}")
        end

        def find_proc_index(procs, id)
          procs.index { |proc| proc.first == id }
        end
      end
    end
  end
end
