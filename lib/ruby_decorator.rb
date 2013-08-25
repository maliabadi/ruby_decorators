class Decorator

  def self.decorate
    RubyDecorators::Stack.all << self
  end

  def decorate
    RubyDecorators::Stack.all << self
  end
end
