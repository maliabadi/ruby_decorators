module RubyDecorators

  class Interface
    extend RubyDecorators
    
    class << self
    
      def named(name)
        @name = name.to_s
        class_eval <<-RUBY_EVAL
          def self.#{@name}(dcr)
            if decorators[dcr]
              self.decorate(decorators[dcr])
            end
          end
        RUBY_EVAL
      end

      def name
        @name ||= self.class.name.to_s
      end

      def decorators
          @decorators ||= {}
      end

      def use *decs
          append = Proc.new do |dec|
            fmt = dec.name.split('::').last.
              gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
              gsub(/([a-z\d])([A-Z])/,'\1_\2').
              tr("-", "_").
              downcase.
              to_sym
            self.decorators[fmt] = dec
          end
          decs.each &append
      end

      def registered_methods
        @registered_methods ||= {}
      end

      def self.registered_decorators
        @registered_decorators ||= {}
      end

    end

  end

end

