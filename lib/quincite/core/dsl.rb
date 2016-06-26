require_relative 'anonymous_proxy'

module Quincite

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
        if block_given?
          last.__send__(name, *args, &proc)
        else
          last.__send__(name, *args)
        end
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
        args = [*args, proc] if block_given?
        component_style_set(name, *args)
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

    def self.component_style_set(name, *args)
      if (worker.acceptable?(:style_include?) and
          worker.transfer(:style_include?, name))
        worker.transfer(:style_set, name, *args)
      elsif worker.acceptable?(:"#{name}=")
        worker.transfer(:"#{name}=", *args)
      else
        raise unless worker.acceptable?(name)
        worker.transfer(name, *args)
      end
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
        def const_missing(name) Quincite::UI.resolve_const(name) end
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
end
