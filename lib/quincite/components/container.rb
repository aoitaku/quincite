module Quincite

  module UI

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
