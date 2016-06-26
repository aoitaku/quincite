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

  end
end
