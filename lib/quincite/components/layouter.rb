module Quincite

  module UI

    module Layouter

      def resize(parent)
        super
        __send__(:"#{layout_style}_resize")
        update_collision
        self
      end

      def move(ox=0, oy=0, parent)
        super
        __send__(:"#{layout_style}_move")
        self
      end

      def flow_resize
        v_margin = padding_top
        @content_width = @width || UI.max_width
        @content_height = components.lazy.each {|component|
          component.resize(self)
        }.slice_before(&components_overflow?).inject(0) {|height, row|
          component = row.max_by(&:layout_height)
          next height if component.position == :absolute
          v_space = [v_margin, component.margin_top].max + height
          v_margin = component.margin_bottom
          v_space + component.height
        } + [v_margin, padding_bottom].max
      end
      private :flow_resize

      def flow_move
        v_margin = padding_top
        components.slice_before(&components_overflow?).inject(0) do |height, row|
          component = row.max_by(&:layout_height)
          max_component_height = component.height
          v_space = [v_margin, component.margin_top].max + height
          v_margin = component.margin_bottom
          inner_width = row.inject(0, &row_injection) + [row.last.margin_right, padding_right].max
          row.inject(0, &row_injection {|component, h_space|
            x = self.x + h_space + case justify_content
            when :space_between
              if row.size > 1 and not row.last.break_after?
                h_space += (self.width - inner_width) / (row.size - 1).to_f
              end
              0
            when :center
              (self.width - inner_width) / 2.0
            when :right
              self.width - inner_width
            else
              0
            end
            y = self.y + v_space + case align_items
            when :center
              (max_component_height - component.height) / 2.0
            when :bottom
              max_component_height - component.height
            else
              0
            end
            if component.position == :absolute
              component.move(self.x, self.y, self)
            else
              component.move(x, y, self)
            end
            h_space
          })
          v_space + max_component_height
        end
      end
      private :flow_move

      def row_injection(&with)
        h_margin = padding_left
        -> width, component do
          h_space = [h_margin, component.margin_left].max + width
          h_space = with.call(component, h_space) if with
          next width if component.position == :absolute
          h_margin = component.margin_right
          h_space + component.width
        end
      end
      private :row_injection

      def vertical_box_resize
        v_margin = padding_top
        @content_height = components.inject(0) {|height, component|
          component.resize(self)
          next height if component.position == :absolute
          v_space = [v_margin, component.margin_top].max + height
          v_margin = component.margin_bottom
          v_space + component.height
        } + [v_margin, padding_bottom].max
        component = components.max_by(&:layout_width)
        if component
          @content_width = component.width +
            [component.margin_left, padding_left].max +
            [component.margin_right, padding_right].max
        end
      end
      private :vertical_box_resize

      def vertical_box_move
        v_margin = padding_top
        components.inject(0) do |height, component|
          h_space = [padding_left, component.margin_left].max
          v_space = [v_margin, component.margin_top].max + height
          x = self.x + h_space + case justify_content
          when :center
            (component.inner_width(self) - component.width) / 2
          when :right
            component.inner_width(self) - component.width
          else
            0
          end
          y = self.y + v_space + case align_items
          when :space_between
            if @height and components.size > 1
              v_space += (@height - @content_height) / (components.size - 1)
            end
            0
          when :center
            @height ? (@height - @content_height) / 2 : 0
          when :bottom
            @height ? @height - @content_height : 0
          else
            0
          end
          if component.position == :absolute
            component.move(self.x, self.y, self)
          else
            component.move(x, y, self)
          end
          next height if component.position == :absolute
          v_margin = component.margin_bottom
          v_space + component.height
        end
      end
      private :vertical_box_move

      def horizontal_box_resize
        h_margin = padding_left
        @content_width = components.inject(0) {|width, component|
          component.resize(self)
          next width if component.position == :absolute
          h_space = [h_margin, component.margin_left].max + width
          h_margin = component.margin_right
          h_space + component.width
        } + [h_margin, padding_right].max
        component = components.max_by(&:layout_height)
        if component
          @content_height = component.height +
            [component.margin_top, padding_top].max +
            [component.margin_bottom, padding_bottom].max
        end
      end
      private :horizontal_box_resize

      def horizontal_box_move
        h_margin = padding_left
        components.inject(0) do |width, component|
          h_space = [h_margin, component.margin_left].max + width
          v_space = [padding_top, component.margin_top].max
          x = self.x + h_space + case justify_content
          when :space_between
            if @width and components.size > 1
              h_space += (@width - @content_width) / (components.size - 1)
            end
            0
          when :center
            @width ? (@width - @content_width) / 2 : 0
          when :right
            @width ? @width - @content_width : 0
          else
            0
          end
          y = self.y + v_space + case align_items
          when :center
            (component.inner_height(self) - component.height) / 2
          when :bottom
            component.inner_height(self) - component.height
          else
            0
          end
          if component.position == :absolute
            component.move(self.x, self.y, self)
          else
            component.move(x, y, self)
          end
          next width if component.position == :absolute
          h_margin = component.margin_right
          h_space + component.width
        end
      end
      private :horizontal_box_move

    end
  end
end