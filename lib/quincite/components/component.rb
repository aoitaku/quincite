module Quincite

  module UI

    module Component

      extend Forwardable

      attr_accessor :id
      attr_reader :style

      attr_reader :content_width, :content_height

      def_delegator  :@style, :position
      def_delegators :@style, :top, :left, :bottom, :right
      def_delegators :@style, :padding_top,  :padding_bottom
      def_delegators :@style, :padding_left, :padding_right
      def_delegators :@style, :bg_image,     :bg_color
      def_delegators :@style, :border_width, :border_color
      def_delegator  :@style, :justify_content
      def_delegator  :@style, :align_items
      def_delegator  :@style, :layout, :layout_style

      def init_component
        @style = Style.new
      end

      def style_include?(name)
        @style.respond_to?("#{name}=")
      end

      def style_set(name, args)
        @style.__send__("#{name}=", args)
      end

      def width
        @width || content_width || 0
      end

      def height
        @height || content_height || 0
      end

      def layout_width
        return 0 if position == :absolute
        width + margin_left + margin_right
      end

      def layout_height
        return 0 if position == :absolute
        height + margin_top + margin_bottom
      end

      def margin_top
        return 0 if position == :absolute
        @style.margin_top
      end

      def margin_right
        return 0 if position == :absolute
        @style.margin_right
      end

      def margin_bottom
        return 0 if position == :absolute
        @style.margin_bottom
      end

      def margin_left
        return 0 if position == :absolute
        @style.margin_left
      end

      def horizontal_margin
        margin_left + margin_right
      end

      def offset_left(parent)
        [parent.padding_left, margin_left].max
      end

      def offset_right(parent)
        [parent.padding_right, margin_right].max
      end

      def horizontal_offset(parent)
        offset_left(parent) + offset_right(parent)
      end

      def vertical_margin
        margin_top + margin_bottom
      end

      def offset_top(parent)
        [parent.padding_top, margin_top].max
      end

      def offset_bottom(parent)
        [parent.padding_bottom, margin_bottom].max
      end

      def vertical_offset(parent)
        offset_top(parent) + offset_bottom(parent)
      end

      def inner_width(parent)
        if parent.respond_to?(:padding_left) && parent.respond_to?(:padding_right)
          parent.width - horizontal_offset(parent)
        else
          parent.width - horizontal_margin
        end
      end

      def inner_height(parent)
        if parent.respond_to?(:padding_top) && parent.respond_to?(:padding_bottom)
          parent.height - vertical_offset(parent)
        else
          parent.height - vertical_margin
        end
      end

      def layout(ox=0, oy=0, parent=RootContainer)
        resize(parent)
        move(ox, oy, parent)
      end

      def move(to_x, to_y, parent)
        move_x(to_x, parent)
        move_y(to_y, parent)
      end

      def move_x(to_x, parent)
        if position == :absolute
          if left and Numeric === left
            case left
            when Fixnum
              self.x = to_x + left
            when Float
              self.x = to_x + (parent.width - self.width) * left
            end
          elsif right and Numeric === right
            case right
            when Fixnum
              self.x = to_x + parent.width - self.width - right
            when Float
              self.x = to_x + (parent.width - self.width) * (1 - right)
            end
          else
            self.x = to_x
          end
        else
          if left and Numeric === left
            case left
            when Fixnum
              self.x = to_x + left
            when Float
              self.x = to_x + left * self.width
            end
          elsif right and Numeric === right
            case right
            when Fixnum
              self.x = to_x - right
            when Float
              self.x = to_x - right * self.width
            end
          else
            self.x = to_x
          end
        end
      end
      private :move_x

      def move_y(to_y, parent)
        if position == :absolute
          if top and Numeric === top
            case top
            when Fixnum
              self.y = to_y + top
            when Float
              self.y = to_y + (parent.height - self.height) * top
            end
          elsif bottom and Numeric === bottom
            case bottom
            when Fixnum
              self.y = to_y + parent.height - self.height - bottom
            when Float
              self.y = to_y + (parent.height - self.height) * (1 - bottom)
            end
          else
            self.y = to_y
          end
        else
          if top and Numeric === top
            case top
            when Fixnum
              self.y = to_y + top
            when Float
              self.y = to_y + top * self.height
            end
          elsif bottom and Numeric === bottom
            case bottom
            when Fixnum
              self.y = to_y - bottom
            when Float
              self.y = to_y - bottom * self.height
            end
          else
            self.y = to_y
          end
        end
      end
      private :move_y

      def resize(parent)
        case @style.width
        when Integer
          @width = @style.width
        when Float
          @width = parent.width * @style.width
        when :full
          @width = inner_width(parent)
        else
          @width = nil
        end
        case @style.height
        when Integer
          @height = @style.height
        when Float
          @height = parent.height * @style.height
        when :full
          @height = inner_height(parent)
        else
          @height = nil
        end
      end

      def break_after?
        !!@style.break_after
      end

      def visible?
        !!@style.visible
      end

    end
  end
end