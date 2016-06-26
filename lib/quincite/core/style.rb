require_relative 'color'

module Quincite

  module UI

    class Style

      extend Forwardable

      attr_accessor :position
      attr_accessor :top, :left, :bottom, :right
      attr_accessor :width,  :height
      attr_reader   :margin, :padding
      attr_accessor :layout
      attr_accessor :justify_content
      attr_accessor :align_items
      attr_accessor :break_after
      attr_accessor :visible

      def_delegator :@bg, :color,  :bg_color
      def_delegator :@bg, :color=, :bg_color=
      def_delegator :@bg, :image,  :bg_image
      def_delegator :@bg, :image=, :bg_image=
      def_delegator :@bg, :bg=

      def_delegator :@border, :width,  :border_width
      def_delegator :@border, :width=, :border_width=
      def_delegator :@border, :color,  :border_color
      def_delegator :@border, :color=, :border_color=
      def_delegator :@border, :border=

      def initialize
        @position        = :relative
        @top             = nil
        @left            = nil
        @bottom          = nil
        @right           = nil
        @width           = nil
        @height          = nil
        @margin          = [0, 0, 0, 0]
        @padding         = [0, 0, 0, 0]
        @layout          = nil
        @justify_content = nil
        @align_items     = nil
        @break_after     = false
        @bg              = Background.new
        @border          = Border.new
        @visible         = true
      end

      def margin=(args)
        case args
        when Numeric
          @margin = [args] * 4
        when Array
          case args.size
          when 1
            @margin = args * 4
          when 2
            @margin = args * 2
          when 3
            @margin = [*args, args[1]]
          when 4
            @margin = args
          else
            @margin = args[0...4]
          end
        else
          @margin = [0, 0, 0, 0]
        end
      end

      def margin_top
        @margin[0]
      end

      def margin_right
        @margin[1]
      end

      def margin_bottom
        @margin[2]
      end

      def margin_left
        @margin[3]
      end

      def padding=(args)
        case args
        when Numeric
          @padding = [args] * 4
        when Array
          case args.size
          when 1
            @padding = args * 4
          when 2
            @padding = args * 2
          when 3
            @padding = [*args, args[1]]
          when 4
            @padding = args
          else
            @padding = args[0...4]
          end
        else
          @padding = [0, 0, 0, 0]
        end
      end

      def padding_top
        @padding[0]
      end

      def padding_right
        @padding[1]
      end

      def padding_bottom
        @padding[2]
      end

      def padding_left
        @padding[3]
      end

      class Background

        attr_accessor :image, :color

        def initialize
          @image = nil
          @color = nil
        end

        def bg=(bg)
          case bg
          when Hash
            @image = bg[:image]
            @color = UI.Color(bg[:color]) || Color[255, 255, 255, 255]
          else
            @image = nil
            @color = nil
          end
        end

      end

      class Border

        attr_accessor :width, :color

        def initialize
          @width = 0
          @color = Color[0, 0, 0]
        end

        def border=(border)
          case border
          when Hash
            @width = border[:width] || 1
            @color = UI.Color(border[:color]) || Color[255, 255, 255, 255]
          else
            @width = nil
            @color = nil
          end
        end

      end

    end
  end
end
