require 'spec_helper'

describe DataMapperRest::Format::Xml do
  describe "uncustomized" do
    subject { DataMapperRest::Format::Xml.new }

    its(:mime) { should == "application/xml" }
    its(:extension) { should == "xml" }

    it "appends the default extension to the resource path" do
      format = DataMapperRest::Format::Xml.new
      format.resource_path(Book.new.model).should == "books.xml"
    end
  end

  describe "custom extension" do
    subject { DataMapperRest::Format::Xml.new(:extension => "data") }

    its(:mime) { should == "application/xml" }
    its(:extension) { should == "data" }

    it "appends the extension to the resource path" do
      format = DataMapperRest::Format::Xml.new(:extension => "data")
      format.resource_path(Book.new.model).should == "books.data"
    end
  end

  describe "no extension" do
    subject { DataMapperRest::Format::Xml.new(:extension => nil) }

    its(:mime) { should == "application/xml" }
    its(:extension) { should be_nil }

    it "does not append an extension to the resource path" do
      format = DataMapperRest::Format::Xml.new(:extension => nil)
      format.resource_path(Book.new.model).should == "books"
    end
  end

  describe "empty extension" do
    subject { DataMapperRest::Format::Xml.new(:extension => "") }

    its(:mime) { should == "application/xml" }
    its(:extension) { should be_nil }

    it "does not append an extension to the resource path" do
      format = DataMapperRest::Format::Xml.new(:extension => "")
      format.resource_path(Book.new.model).should == "books"
    end
  end
  
  describe "#string_representation" do
    before(:each) do
      @format = DataMapperRest::Format::Xml.new
    end

    it "returns an XML string representing the resource" do
      pending "It doesn't make sense that the XML being sent to the server is different to the XML being returned??"
      book = Book.new(:title => "Testing", :author => "Testy McTesty")
      puts @format.string_representation(book)
    end
  end
end
