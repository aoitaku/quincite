module Quincite

  module UI

    class Color

      attr_accessor :red, :green, :blue, :alpha

      def initialize(rgb:, alpha: 255)
        @red, @green, @blue = *rgb
        @alpha = alpha
      end

      def self.from_array(color)
        case color.size
        when 3
          self.new(rgb: color)
        when 4
          self.new(rgb: color.take(3), alpha: color.last)
        else
          nil
        end
      end

      def self.from_hex(color)
        sefl.new(rgb: [
          color >> 16 & 0xff,
          color >> 8 & 0xff,
          color & 0xff
        ])
      end

      def self.from_hexstring(color)
        sefl.new(rgb: [
          color[1..2].hex,
          color[3..4].hex,
          color[5..6].hex
        ])
      end

      def self.[](*rgba)
        self.from_array(rgba)
      end

    end

    def Color(color)
      case color
      when Array
        Color.from_array(color)
      when Fixnum
        Color.from_hex(color)
      when /^#[0-9a-fA-F]{6}$/
        Color.from_hexstring(color)
      else
        nil
      end
    end

  end
end
