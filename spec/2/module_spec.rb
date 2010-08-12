require 'zucker/2/module'

module Blip
  def blip
    'blip'
  end
  alias_methods_for :blip, :blap, :blup
  
  class << self
    def self_blip
      'blip'
    end
    alias_methods_for :self_blip, :self_blap, :self_blup
  end  
end

class Hello
  include Blip
  
  def hello
    'hello'
  end
  alias_methods_for :hello, :hi, :howdy
  
  class << self
    def self_hello
      'hello'
    end
    alias_methods_for :self_hello, :self_hi, :self_howdy
  end  
  
end

describe 'alias_methods_for' do
  let(:h) { Hello.new}

  context "module context" do
    it "should alias instance methods" do
      h.blap.should == h.blip
      h.blup.should == h.blip
    end

    it "should alias class methods" do
      Blip.self_blap.should == Blip.self_blip
      Blip.self_blup.should == Blip.self_blip
    end
  end

  context "class context" do  
    it "should alias instance methods" do
      h.hi.should == h.hello
      h.howdy.should == h.hello
    end

    it "should alias class methods" do
      Hello.self_hi.should == Hello.self_hello
      Hello.self_howdy.should == Hello.self_hello
    end
  end
end

