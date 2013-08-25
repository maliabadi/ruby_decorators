require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Hi < RubyDecorators::Decorator
  def call(this, *args, &blk)
    this.call(*args, &blk).sub('hello', 'hi')
  end
end

class Batman < RubyDecorators::Decorator
  def call(this, *args, &blk)
    this.call(*args, &blk).sub('world', 'batman')
  end
end

class BatMan < RubyDecorators::Decorator
  def call(this, *args, &blk)
    this.call(*args, &blk)
  end
end

class Dummy < RubyDecorators::Interface
  
  use Batman, BatMan
  named :dummy

  def initialize
    @greeting = 'hello world'
  end
  
  dummy Batman
  def hello_world
    @greeting
  end
  
  dummy :batman
  def hey_there
    @greeting
  end
end

class MyClient < RubyDecorators::Interface

  use Batman, BatMan
  named :dummy

  def initialize
    @greeting = 'hello world'
  end

  dummy :batman
  def hello_world
    @greeting
  end

end

describe RubyDecorators::Interface do

  describe "add decorator" do
    
    it "registers non-camel-cased classes as one word" do
      Dummy.decorators.keys.include?(:batman).must_equal true
      Dummy.decorators[:batman].must_equal Batman
    end

    it "registers camel-cased classes as underscored symbols" do
      Dummy.decorators.keys.include?(:bat_man).must_equal true
      Dummy.decorators[:bat_man].must_equal BatMan
    end
    
    it "responds to the named method" do
      Dummy.name.must_equal "dummy"
    end

    it "wraps dummy with symbol refrence" do
      Dummy.new.hey_there.must_equal "hello batman"
    end

  end

  describe MyClient do

    before do
      @dummy = MyClient.new()
    end
    
    it "inherits the class methods and wrappers" do
      @dummy.hello_world.must_equal "hello batman"
    end

  end

end