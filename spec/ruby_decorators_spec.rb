require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'minitest/autorun'

class DummyDecorator < RubyDecorator
  def call(this)
    'I should never be called'
  end
end

class Hi < RubyDecorator
  def call(this, *args, &blk)
    this.call(*args, &blk).sub('hello', 'hi')
  end
end

class Batman < RubyDecorator
  def call(this, *args, &blk)
    this.call(*args, &blk).sub('world', 'batman')
  end
end

class Catwoman < RubyDecorator
  def initialize(*args)
    @args = args.any? ? args : ['catwoman']
  end

  def call(this, *args, &blk)
    this.call(*args, &blk).sub('world', @args.join(' '))
  end
end



class DummyClass2
  extend RubyDecorators
  
  decorate Hi
  def hi
    'hello'
  end
end



class DummyClass
  extend RubyDecorators

  def initialize
    @greeting = 'hello world'
  end

  def hello_world
    @greeting
  end

  decorate Batman
  def hello_public
    @greeting
  end

  decorate DummyDecorator
  def hello_void
    @greeting
  end

  def hello_untouched
    @greeting
  end

  decorate Batman
  def hello_with_args(arg1, arg2)
    "#{@greeting} #{arg1} #{arg2}"
  end

  decorate Catwoman
  def hello_catwoman
    @greeting
  end

  decorate Batman
  def hello_with_block(arg1, arg2, &block)
    "#{@greeting} #{arg1} #{arg2} #{block.call if block_given?}"
  end

  decorate Catwoman.new('super', 'catwoman')
  def hello_super_catwoman
    @greeting
  end

  decorate Hi
  decorate Batman
  def hi_batman
    @greeting
  end

  decorate Hi
  decorate Catwoman.new('super', 'catwoman')
  def hi_super_catwoman(arg1)
    "#{@greeting}#{arg1}"
  end

  protected

  decorate Batman
  def hello_protected
    @greeting
  end

  private

  decorate Batman
  def hello_private
    @greeting
  end
end

describe DummyClass2 do
  before do
    @dummy = DummyClass2.new
  end

  it "#hello_world" do
    @dummy.hi.must_equal 'hi'
  end
end
  

describe DummyClass do

  before do
    @dummy = DummyClass.new
  end

  it "#hello_world" do
    @dummy.hello_world.must_equal 'hello world'
  end

  it "decorates a public method" do
    @dummy.hello_public.must_equal 'hello batman'
  end

  it "decorates a protected method" do
    @dummy.send(:hello_protected).must_equal 'hello batman'
    lambda { @subject.hello_protected }.must_raise NoMethodError
  end

  it "decorates a private method" do
    @dummy.send(:hello_private).must_equal 'hello batman'
    lambda { @dummy.hello_private }.must_raise NoMethodError
  end

  it "decorates a method with args" do
    @dummy.hello_with_args('how are', 'you?').must_equal 'hello batman how are you?'
  end

  it "decorates a method with a block" do
    @dummy.hello_with_block('how are', 'you') { 'man?' }.must_equal 'hello batman how are you man?'
  end

  it "ignores undecorated methods" do
    @dummy.hello_untouched.must_equal 'hello world'
  end

  describe "a decorator with args" do
    it "decorates without any decorator args" do
      @dummy.hello_catwoman.must_equal 'hello catwoman'
    end

    it "decorate a simple method" do
      @dummy.hello_super_catwoman.must_equal 'hello super catwoman'
    end
  end

  describe "multiple decorators" do
    it "decorates a simple method" do
      @dummy.hi_batman.must_equal 'hi batman'
    end

    it "decorates a method with args" do
      @dummy.hi_super_catwoman('!').must_equal 'hi super catwoman!'
    end
  end
end
