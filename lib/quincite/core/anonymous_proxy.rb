module Quincite

  module AnonymousProxy

    def anon_proxy(name, sup=BasicObject, &proc)
      instance_variable_set(:"@#{name}", Class.new(sup, &proc).new)
      class_eval("def self.#{name}() @#{name} end")
    end

  end
end
