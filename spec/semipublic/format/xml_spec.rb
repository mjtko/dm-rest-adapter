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
      @time = DateTime.now
      @xml = DataMapper::Ext::String.compress_lines(<<-XML)
        <book>
          <id type="integer">1</id>
          <created_at type="datetime">#{@time.to_s}</created_at>
          <title>Testing</title>
          <author>Testy McTesty</author>
        </book>
      XML
    end

    it "returns an XML string representing the resource" do
      book = Book.new(
        :id         => 1,
        :created_at => @time,
        :title      => "Testing",
        :author     => "Testy McTesty"
      )
      book_xml = DataMapper::Ext::String.compress_lines(@format.string_representation(book))
      book_xml.should == @xml
    end
  end
  
  describe "#update_attributes" do
    before(:each) do
      @format = DataMapperRest::Format::Xml.new
      @time = DateTime.new
      @xml = DataMapper::Ext::String.compress_lines(<<-XML)
        <book>
          <id type="integer">1</id>
          <created_at type="datetime">#{@time.to_s}</created_at>
          <title>Testing</title>
          <author>Testy McTesty</author>
        </book>
      XML
    end
    
    it "updates the attributes in the resource based on the response" do
      book = Book.new
      @format.update_attributes(book, @xml)
      
      book.id.should == 1
      book.created_at.should == @time
      book.title.should == "Testing"
      book.author.should == "Testy McTesty"
    end
  end
  
  describe "#parse_record" do
    before(:each) do
      @format = DataMapperRest::Format::Xml.new
      @time = DateTime.new
      @xml = DataMapper::Ext::String.compress_lines(<<-XML)
        <book>
          <id type="integer">1</id>
          <created_at type="datetime">#{@time.to_s}</created_at>
          <title>Testing</title>
          <author>Testy McTesty</author>
        </book>
      XML
    end
    
    it "loads a record from the string representation" do
      record = @format.parse_record(@xml, Book)
      record["id"].should == 1
      record["created_at"].should == @time
      record["title"].should == "Testing"
      record["author"].should == "Testy McTesty"
    end
  end
  
  describe "#parse_collection" do
    before(:each) do
      @format = DataMapperRest::Format::Xml.new
      @time = DateTime.new
      @xml = DataMapper::Ext::String.compress_lines(<<-XML)
        <books>
          <book>
            <id type="integer">1</id>
            <created_at type="datetime">#{@time.to_s}</created_at>
            <title>Testing</title>
            <author>Testy McTesty</author>
          </book>
          <book>
            <id type="integer">2</id>
            <created_at type="datetime">#{@time.to_s}</created_at>
            <title>Testing 2</title>
            <author>Besty McBesty</author>
          </book>
        </books>
      XML
    end
    
    it "loads a recordset from the string representation" do
      collection = @format.parse_collection(@xml, Book)
      collection.should have(2).entries
      collection[0]["id"].should == 1
      collection[0]["created_at"].should == @time
      collection[0]["title"].should == "Testing"
      collection[0]["author"].should == "Testy McTesty"
      collection[1]["id"].should == 2
      collection[1]["created_at"].should == @time
      collection[1]["title"].should == "Testing 2"
      collection[1]["author"].should == "Besty McBesty"
    end
  end
end
