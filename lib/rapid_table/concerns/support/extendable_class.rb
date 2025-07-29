require "active_support/core_ext/string/inflections"

module RapidTable
  module Support
    module ExtendableClass
      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      class Base
        def initialize(options = {})
          options.each do |key, value|
            send("#{key}=", value)
          end
        end

        def becomes(klass)
          unless klass < self.class
            raise ArgumentError, "cannot become #{klass.inspect} because it's not a subclass of #{self.class.inspect}"
          end

          klass.new(to_h)
        end

        def to_h
          instance_variables.each_with_object({}) do |var, hash|
            hash[var.to_s.delete("@").to_sym] = instance_variable_get(var)
          end
        end
      end

      module ClassMethods
        def def_extendable_class(id, name: nil, superclass: nil, &block)
          extendable_classes_by_id[id] ||= new_extendable_class(id, name:, superclass:, &block)
        end

        def new_extendable_class(id, name: nil, superclass: nil, &block)
          klass = Class.new(superclass || default_extendable_superclass)

          # give it a name underneath the current class
          const_set(name || id.to_s.camelize, klass) if name || self.name

          # define some syntactic sugar
          define_singleton_method(:"#{id}_class!") do |&block|
            extend_class(id, &block)
          end

          define_singleton_method(:"#{id}_class") do
            find_extendable_class(id)
          end

          define_singleton_method(:"build_#{id}") do |attrs|
            build_extendable_instance(id, attrs)
          end

          define_singleton_method(:"build_#{id.to_s.pluralize}") do |array|
            build_extendable_instances(id, array)
          end

          klass.class_eval(&block) if block_given?
          klass
        end

        def default_extendable_superclass
          superclass = nil
          if self.superclass.respond_to?(:find_extendable_class)
            superclass ||= self.superclass.find_extendable_class(id)
          end
          superclass || Base
        end

        # giving a block implies you're extending the existing class
        # so the extendable class needs to be attached to ONLY this class
        # otherwise you can access the superclass's extendable class
        def extend_class(id, &)
          # ensures the ID is valid
          existing = find_extendable_class!(id)

          klass = if block_given?
                    extendable_classes_by_id[id] || def_extendable_class(id,
                                                                         superclass: existing,
                                                                        )
                  else
                    existing
                  end
          klass.class_eval(&) if block_given?
          klass
        end

        def find_extendable_class(id)
          extendable_classes_by_id[id] ||
            (superclass.find_extendable_class(id) if superclass.respond_to?(:find_extendable_class))
        end

        def find_extendable_class!(id)
          find_extendable_class(id) || raise(ExtendableClassNotFoundError, "extendable class #{id.inspect} not found")
        end

        def build_extendable_instance(id, attrs)
          klass = find_extendable_class!(id)

          if klass < attrs.class
            attrs.becomes(klass)
          elsif attrs.is_a?(klass)
            attrs
          elsif attrs.is_a?(Hash) || attrs.is_a?(ActiveSupport::HashWithIndifferentAccess)
            klass.new(attrs)
          else
            raise ArgumentError, "attrs must be a #{klass} or a Hash"
          end
        end

        def build_extendable_instances(id, array)
          array.map { |attrs| build_extendable_instance(id, attrs) }
        end

        def extendable_classes_by_id
          @extendable_classes_by_id ||= {}
        end
      end
    end
  end
end
