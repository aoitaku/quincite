module Quincite

  module UI

    module RootContainer

      def self.width
        UI.max_width
      end

      def self.height
        UI.max_height
      end

    end

    @max_width  = 0
    @max_height = 0

    def self.max_width
      @max_width
    end

    def self.max_height
      @max_height
    end

    def self.max_width=(width)
      @max_width = width
    end

    def self.max_height=(height)
      @max_height = height
    end

  end
end