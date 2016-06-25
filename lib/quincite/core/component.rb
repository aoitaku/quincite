module Quincite

  module UI

    module Event

      def fire(type, current_target, target, *args)
        __send__(type, current_target, target, *args)
      end

    end

    module EventHandler

      attr_reader :event_handlers

      module EventHandlerUtils

        def event_handler(*names) names.each {|name| class_eval(<<-EOD) } end
          def on_#{name}(*args)
            event_handlers[:#{name}] and instance_exec(*args, &event_handlers[:#{name}])
          end
        EOD

      end

      def self.included(klass)
        klass.extend(EventHandlerUtils)
      end

    end

    module EventDispatcher

      attr_accessor :event_listener
      attr_reader :event

      def initialize(event_listener)
        @event_listener = event_listener
      end

    end

    module Control

      def init_control
        @event_handlers = {}
      end

      def add_event_handler(name, event_handler)
        @event_handlers[name] = event_handler
      end

    end

    module Container

      attr_reader :components

      def self.try_to_a(obj)
        obj.respond_to?(:to_a) and obj.to_a
      end

      def init_container
        @components = []
      end

      def add(obj)
        components << obj
      end

      def receive(event)
        event.fire(*components) or event.execute(self)
      end

      def to_a
        [self, *components.map {|obj| Container.try_to_a(obj) or obj }]
      end

      def all_components
        to_a.flatten
      end

      def all(order=:asc)
        order == :desc ? all_components.reverse : all_components
      end

      def find(id)
        all_components.find {|obj| obj.id == id }
      end

    end
  end
end
