module Quincite

  module UI

    module Control

      def init_control
        @event_handlers = {}
      end

      def add_event_handler(name, event_handler)
        @event_handlers[name] = event_handler
      end

    end

  end
end
