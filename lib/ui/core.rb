require_relative 'core/symbol'
require_relative 'core/anonymous_proxy'

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

module UI

  extend AnonymousProxy

  anon_proxy :gateway do

    def method_missing(name, *args, &proc)
      if proc
        UI.resolve_method(name, *args, &proc)
      else
        UI.resolve_method(name, *args)
      end
    end

    def respond_to?(name)
      UI.worker.acceptable?(name)
    end

  end

  anon_proxy :worker, Array do

    def transfer(name, *args)
      last.__send__(name, *args)
    end

    def acceptable?(name)
      last.respond_to?(name)
    end

    def run_with_stack(o)
      push o
      yield
      pop
    end

  end

  @namespace = self

  def self.namespace=(namespace)
    @namespace = namespace
  end

  def self.namespace
    @namespace
  end

  def self.resolve_const(name)
    build_component(name)
  end

  def self.resolve_method(name, *args)
    if name.match(/^[A-Z]/)
      if block_given?
        build_component(name, *args) { gateway.instance_eval(&proc) }
      else
        build_component(name, *args)
      end
    else
      if block_given?
        component_helper_call(name, *args) { gateway.instance_eval(&proc) }
      elsif args.size == 1
        component_attr_set(name, *args)
      else
        component_helper_call(name, *args)
      end
    end
  end

  def self.new_component(name, *args)
    namespace.const_get(name).new(*args)
  end

  def self.build_component(name, *args)
    if block_given?
      component = worker.run_with_stack(new_component(name, *args), &proc)
    else
      component = new_component(name, *args)
    end
    if worker.empty?
      component
    else
      worker.transfer(:add, component)
    end
  end

  def self.component_helper_call(name, *args)
    raise unless worker.acceptable?(name)
    if block_given?
      worker.transfer(name, *args, &proc)
    else
      worker.transfer(name, *args)
    end
  end

  def self.component_attr_set(name, *args)
    raise unless worker.acceptable?(:"#{name}=")
    worker.transfer(:"#{name}=", *args)
  end

  def self.build(container, &proc)
    container = Class.new { include container } if container.class == Module
    setup_build(proc)
    worker.run_with_stack(container.new){
      gateway.instance_eval(&proc)
    }.tap { cleanup_build(proc) }
  end

  def self.setup_build(proc) proc.binding.eval <<-EOD end
    class << self.class
      alias __const_missing__ const_missing if defined? const_missing
      def const_missing(name) UI.resolve_const(name) end
    end
  EOD

  def self.cleanup_build(proc) proc.binding.eval <<-EOD end
    class << self.class
      remove_method :const_missing
      if defined? __const_missing__
        alias const_missing __const_missing__
        remove_method :__const_missing__
      end
    end
  EOD

end
