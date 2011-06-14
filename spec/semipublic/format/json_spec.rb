require 'spec_helper'

describe DataMapperRest::Format::Json do
  describe "uncustomized" do
    subject { DataMapperRest::Format::Json.new }
    
    its(:mime) { should == "application/json" }
    its(:extension) { should == "json" }
    
    it "appends the default extension to the resource path" do
      format = DataMapperRest::Format::Json.new
      format.resource_path(Book.new.model).should == "books.json"
    end
  end

  describe "custom extension" do
    subject { DataMapperRest::Format::Json.new(:extension => "yml") }
    
    its(:mime) { should == "application/json" }
    its(:extension) { should == "yml" }
    
    it "appends the extension to the resource path" do
      format = DataMapperRest::Format::Json.new(:extension => "data")
      format.resource_path(Book.new.model).should == "books.data"
    end
  end

  describe "no extension" do
    subject { DataMapperRest::Format::Json.new(:extension => nil) }
    
    its(:mime) { should == "application/json" }
    its(:extension) { should be_nil }
    
    it "does not append an extension to the resource path" do
      format = DataMapperRest::Format::Json.new(:extension => nil)
      format.resource_path(Book.new.model).should == "books"
    end
  end

  describe "empty extension" do
    subject { DataMapperRest::Format::Json.new(:extension => "") }
    
    its(:mime) { should == "application/json" }
    its(:extension) { should be_nil }
    
    it "does not append an extension to the resource path" do
      format = DataMapperRest::Format::Json.new(:extension => nil)
      format.resource_path(Book.new.model).should == "books"
    end
  end
  
  describe "#string_representation" do
    before(:each) do
      @format = DataMapperRest::Format::Json.new
      @time = DateTime.now
      @json = '{"id":1,"created_at":"' + @time.to_s + '","title":"Testing","author":"Testy McTesty"}'
    end

    it "returns a JSON string representing the resource" do
      book = Book.new(
        :id         => 1,
        :created_at => @time,
        :title      => "Testing",
        :author     => "Testy McTesty"
      )
      book_json = @format.string_representation(book)
      book_json.should == @json
    end
  end
  
  describe "#update_attributes" do
    before(:each) do
      @format = DataMapperRest::Format::Json.new
      @time = DateTime.new
      @json = '{"id":1,"created_at":"' + @time.to_s + '","title":"Testing","author":"Testy McTesty"}'
    end
    
    it "updates the attributes in the resource based on the response" do
      book = Book.new
      @format.update_attributes(book, @json)
      
      book.id.should == 1
      book.created_at.should == @time
      book.title.should == "Testing"
      book.author.should == "Testy McTesty"
    end
  end
  
  describe "#parse_record" do
    before(:each) do
      @format = DataMapperRest::Format::Json.new
      @time = DateTime.new
      @json = '{"id":1,"created_at":"' + @time.to_s + '","title":"Testing","author":"Testy McTesty"}'
    end
    
    it "loads a record from the string representation" do
      record = @format.parse_record(@json, Book)
      record["id"].should == 1
      record["created_at"].should == @time
      record["title"].should == "Testing"
      record["author"].should == "Testy McTesty"
    end
  end
  
  describe "#parse_collection" do
    before(:each) do
      @format = DataMapperRest::Format::Json.new
      @time = DateTime.new
      @json = '[{"id":1,"created_at":"' + @time.to_s + '","title":"Testing","author":"Testy McTesty"},' +
        '{"id":2,"created_at":"' + @time.to_s + '","title":"Testing 2","author":"Besty McBesty"}]'
    end
    
    it "loads a recordset from the string representation" do
      collection = @format.parse_collection(@json, Book)
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
