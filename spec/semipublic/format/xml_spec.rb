require 'spec_helper'

describe DataMapperRest::Format::Xml do
  describe "uncustomized" do
    subject { DataMapperRest::Format::Xml.new }
    
    its(:mime) { should == "application/xml" }
    its(:extension) { should == "xml" }
  end

  describe "custom extension" do
    subject { DataMapperRest::Format::Xml.new(:extension => "data") }
    
    its(:mime) { should == "application/xml" }
    its(:extension) { should == "data" }
  end

  describe "no extension" do
    subject { DataMapperRest::Format::Xml.new(:extension => nil) }
    
    its(:mime) { should == "application/xml" }
    its(:extension) { should be_nil }
  end

  describe "empty extension" do
    subject { DataMapperRest::Format::Xml.new(:extension => "") }
    
    its(:mime) { should == "application/xml" }
    its(:extension) { should be_nil }
  end
end
