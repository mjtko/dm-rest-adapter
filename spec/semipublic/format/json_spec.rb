require 'spec_helper'

describe DataMapperRest::Format::Json do
  describe "uncustomized" do
    subject { DataMapperRest::Format::Json.new }
    
    its(:mime) { should == "application/json" }
    its(:extension) { should == "json" }
  end

  describe "custom extension" do
    subject { DataMapperRest::Format::Json.new(:extension => "yml") }
    
    its(:mime) { should == "application/json" }
    its(:extension) { should == "yml" }
  end

  describe "no extension" do
    subject { DataMapperRest::Format::Json.new(:extension => nil) }
    
    its(:mime) { should == "application/json" }
    its(:extension) { should be_nil }
  end

  describe "empty extension" do
    subject { DataMapperRest::Format::Json.new(:extension => "") }
    
    its(:mime) { should == "application/json" }
    its(:extension) { should be_nil }
  end
end
