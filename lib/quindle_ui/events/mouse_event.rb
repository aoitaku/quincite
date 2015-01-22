class Quindle::MouseEvent

  include Quindle::UI::Event

  def mouse_out(target, current_target, *args)
    if current_target == target
      current_target.hoverout
      current_target.on_mouse_leave(target, *args)
    end
    current_target.on_mouse_out(target, *args)
  end

  def mouse_move(target, current_target, *args)
    current_target.on_mouse_move(target, *args)
  end

  def mouse_over(target, current_target, *args)
    if current_target == target
      current_target.hoverover
      current_target.on_mouse_enter(target, *args)
    end
    current_target.on_mouse_over(target, *args)
  end

  def mouse_left_push(target, current_target, *args)
    current_target.on_mouse_left_push(target, *args)
  end

  def mouse_left_down(target, current_target, *args)
    current_target.on_mouse_left_down(target, *args)
  end

  def mouse_left_release(target, current_target, *args)
    current_target.on_mouse_left_release(target, *args)
  end

  def mouse_middle_push(target, current_target, *args)
    current_target.on_mouse_middle_push(target, *args)
  end

  def mouse_middle_down(target, current_target, *args)
    current_target.on_mouse_middle_down(target, *args)
  end

  def mouse_middle_release(target, current_target, *args)
    current_target.on_mouse_middle_release(target, *args)
  end

  def mouse_right_push(target, current_target, *args)
    current_target.on_mouse_right_push(target, *args)
  end

  def mouse_right_down(target, current_target, *args)
    current_target.on_mouse_right_down(target, *args)
  end

  def mouse_right_release(target, current_target, *args)
    current_target.on_mouse_right_release(target, *args)
  end

end

module Quindle::MouseEventHandler

  include Quindle::UI::EventHandler

  event_handler :mouse_over, :mouse_move, :mouse_out
  event_handler :mouse_enter, :mouse_leave
  event_handler :mouse_left_push,   :mouse_left_down,   :mouse_left_release
  event_handler :mouse_middle_push, :mouse_middle_down, :mouse_middle_release
  event_handler :mouse_right_push,  :mouse_right_down,  :mouse_right_release

  attr_writer :hover, :active

  def initialize(*args)
    super(*args)
    @hover = false
    @active = false
  end

  def hover?
    @hover
  end

  def hoverover
    @hover = true
  end

  def hoverout
    @hover = false
  end

  def active?
    @active
  end

  def activate
    @active = true
  end

  def deactivate
    @active = false
  end

end
