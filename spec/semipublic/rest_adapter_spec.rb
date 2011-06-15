require 'spec_helper'

describe DataMapper::Adapters::RestAdapter do
  before(:each) do
    @format = double("format")
    
    @adapter = DataMapper::Adapters::RestAdapter.new(:test, DataMapper::Mash[{
      :host     => "test.tld",
      :port     => 81,
      :user     => "admin",
      :password => "secret",
      :format   => @format
    }])
    @adapter.rest_client = double("rest_client")
    
    @response = double("response")
  end
  
  describe "#initialize" do
    before(:each) do
      @adapter = DataMapper::Adapters::RestAdapter.new(:test, DataMapper::Mash[{
        :host     => "test.tld",
        :port     => 81,
        :user     => "admin",
        :password => "secret",
        :format   => double()
      }])
    end
    
    it "prepares a RestClient::Resource for the URI of the REST service" do
      @adapter.rest_client.url.to_s.should == "http://admin:secret@test.tld:81"
    end
  end
  
  describe "#create" do
    describe "when provided a Resource" do
      before(:each) do
        @resource  = Book.new(
          :created_at => DateTime.parse("2009-05-17T22:38:42-07:00"),
          :title => "DataMapper",
          :author => "Dan Kubb"
        )
        @resources = [ @resource ]
      end
      
      it "should ask the format for the path to each Model" do
        @format.should_receive(:resource_path).with(@resource.model)
        stub_mocks!
        @adapter.create(@resources)
      end
      
      it "should query the resource path" do
        @format.stub(:resource_path) { "books.mock" }
        @adapter.rest_client.should_receive(:[]).with("books.mock").and_return(@adapter.rest_client)
        stub_mocks!
        @adapter.create(@resources)
      end
      
      it "should ask the format to serialize each Resource" do
        @format.should_receive(:string_representation).with(@resource)
        stub_mocks!
        @adapter.create(@resources)
      end
      
      it "should POST the serialized Resource to the resource path" do
        @format.stub(:string_representation) { "<<a useless format>>" }
        @adapter.rest_client.should_receive(:post).with("<<a useless format>>", { :content_type => "application/mock" }).and_return(@response)
        stub_mocks!
        @adapter.create(@resources)
      end
      
      it "should ask the format to update the resource with the response" do
        @response.should_receive(:body) { "<<a useless format>>" }
        @format.should_receive(:update_attributes).with(@resource, "<<a useless format>>")
        stub_mocks!
        @adapter.create(@resources)
      end
      
      it "should return an Array of the records" do
        stub_mocks!
        @adapter.create(@resources).should eql @resources
      end
    end
  end

  describe "#read" do
    context "with unscoped query" do
      before(:each) do
        @query = Book.all.query
        @resources = [ {} ]
      end
      
      it "should ask the format for the resource path" do
        @format.should_receive(:resource_path).with(Book)
        stub_mocks!
        @adapter.read(@query)
      end
      
      it "should query the resource path" do
        @format.stub(:resource_path) { "books.mock" }
        @adapter.rest_client.should_receive(:[]).with("books.mock").and_return(@adapter.rest_client)
        stub_mocks!
        @adapter.read(@query)
      end
      
      it "should use GET" do
        @adapter.rest_client.should_receive(:get) { @response }
        stub_mocks!
        @adapter.read(@query)
      end
      
      it "should delegate to the Format to parse the response" do
        @response.should_receive(:body) { "<<a collection>>" }
        @format.should_receive(:parse_collection).with("<<a collection>>", Book).and_return(@resources)
        stub_mocks!
        @adapter.read(@query).should eql @resources
      end
    end

    context "with query scoped by a key" do
      before(:each) do
        @query = Book.all(:id => 1, :limit => 1).query
        @record  = {
          "id" => 1,
          "created_at" => DateTime.parse("2009-05-17T22:38:42-07:00"),
          "title" => "DataMapper",
          "author" => "Dan Kubb"
        }
        @records = [ @record ]
      end
      
      it "should ask the format for the resource path using the key" do
        @format.should_receive(:resource_path).with(Book, 1)
        stub_mocks!
        @adapter.read(@query)
      end
      
      it "should query the resource path" do
        @format.stub(:resource_path) { "books/1.mock" }
        @adapter.rest_client.should_receive(:[]).with("books/1.mock").and_return(@adapter.rest_client)
        stub_mocks!
        @adapter.read(@query)
      end
      
      it "should use GET" do
        @adapter.rest_client.should_receive(:get) { @response }
        stub_mocks!
        @adapter.read(@query)
      end
      
      it "should delegate to the Format to parse the response" do
        @response.should_receive(:body) { "<<a resource>>" }
        @format.should_receive(:parse_record).with("<<a resource>>", Book).and_return(@record)
        stub_mocks!
        @adapter.read(@query).should eql @records
      end
      
      it "gracefully returns an empty collection on 404" do
        @adapter.rest_client.should_receive(:get).and_raise(RestClient::ResourceNotFound)
        stub_mocks!
        @adapter.read(@query).should be_empty
      end
    end

    context "with query scoped by a non-key" do
      before(:each) do
        @query = Book.all(:author => "Dan Kubb").query
        @record  = {
          "id" => 1,
          "created_at" => DateTime.parse("2009-05-17T22:38:42-07:00"),
          "title" => "DataMapper",
          "author" => "Dan Kubb"
        }
        @records = [ @record ]
      end
      
      it "should ask the format for the resource path" do
        @format.should_receive(:resource_path).with(Book)
        stub_mocks!
        @adapter.read(@query)
      end
      
      it "should query the resource path" do
        @format.stub(:resource_path) { "books.mock" }
        @adapter.rest_client.should_receive(:[]).with("books.mock").and_return(@adapter.rest_client)
        stub_mocks!
        @adapter.read(@query)
      end
      
      it "should use GET with the conditions appended as params" do
        @adapter.rest_client.should_receive(:get).with(:params => { :author => "Dan Kubb" }).and_return(@response)
        stub_mocks!
        @adapter.read(@query)
      end
      
      it "should delegate to the Format to parse the response" do
        @response.should_receive(:body) { "<<a collection>>" }
        @format.should_receive(:parse_collection).with("<<a collection>>", Book).and_return(@records)
        stub_mocks!
        @adapter.read(@query).should eql @records
      end
    end
  end

  describe "#update" do
    before(:each) do
      @resource  = Book.new(
        :id => 1,
        :created_at => DateTime.parse("2009-05-17T22:38:42-07:00"),
        :title => "DataMapper",
        :author => "Dan Kubb"
      )
      @resources = [ @resource ]
    end
    
    it "should ask the format for the resource path using the key" do
      @format.should_receive(:resource_path).with(@resource.model, "1")
      stub_mocks!
      @adapter.update({ Book.properties[:author] => "John Doe" }, @resources)
    end
    
    it "should query the resource path" do
      @format.stub(:resource_path) { "books/1.mock" }
      @adapter.rest_client.should_receive(:[]).with("books/1.mock").and_return(@adapter.rest_client)
      stub_mocks!
      @adapter.update({ Book.properties[:author] => "John Doe" }, @resources)
    end
    
    it "should ask the Format to serialize each Resource" do
      @format.should_receive(:string_representation).with(@resource)
      stub_mocks!
      @adapter.update({ Book.properties[:author] => "John Doe" }, @resources)
    end
    
    it "should PUT the serialized Resource to the path" do
      @format.stub(:string_representation) { "<<a useless format>>" }
      @adapter.rest_client.should_receive(:put).with("<<a useless format>>", { :content_type => "application/mock" }).and_return(@response)
      stub_mocks!
      @adapter.update({ Book.properties[:author] => "John Doe" }, @resources)
    end
    
    it "should return the number of updated Resources" do
      stub_mocks!
      @adapter.update({ Book.properties[:author] => "John Doe" }, @resources).should == 1
    end
    
    it "should modify the resource" do
      stub_mocks!
      @adapter.update({ Book.properties[:author] => "John Doe" }, @resources)
      @resource.author.should == "John Doe"
    end
    
    it "should ask the format to update the resource with the response" do
      @response.should_receive(:body) { "<<a useless format>>" }
      @format.should_receive(:update_attributes).with(@resource, "<<a useless format>>")
      stub_mocks!
      @adapter.update({ Book.properties[:author] => "John Doe" }, @resources)
    end
  end

  describe "#delete" do
    before(:each) do
      @resource  = Book.new(
        :id => 1,
        :created_at => DateTime.parse("2009-05-17T22:38:42-07:00"),
        :title => "DataMapper",
        :author => "Dan Kubb"
      )
      @resources = [ @resource ]
    end
    
    it "should ask the format for the resource path using the key" do
      @format.should_receive(:resource_path).with(@resource.model, "1")
      stub_mocks!
      @adapter.delete(@resources)
    end
    
    it "should query the resource path" do
      @format.stub(:resource_path) { "books/1.mock" }
      @adapter.rest_client.should_receive(:[]).with("books/1.mock").and_return(@adapter.rest_client)
      stub_mocks!
      @adapter.delete(@resources)
    end
    
    it "should DELETE the resource from the path" do
      @adapter.rest_client.should_receive(:delete).and_return(@response)
      stub_mocks!
      @adapter.delete(@resources)
    end
    
    it "should return the number of deleted Resources" do
      stub_mocks!
      @adapter.delete(@resources).should == 1
    end
  end
  
  def stub_mocks!
    {
      :resource_path => "mock",
      :mime => "application/mock",
      :string_representation => "<<mock format>>",
      :update_attributes => double(),
      :parse_collection => [],
      :parse_record => double()
    }.each_pair { |meth, ret| @format.stub(meth) { ret } unless @format.respond_to?(meth) }
    
    {
      :[] => @adapter.rest_client,
      :get => @response,
      :post => @response,
      :put => @response,
      :delete => @response,
    }.each_pair { |meth, ret| @adapter.rest_client.stub(meth) { ret } unless @adapter.rest_client.respond_to?(meth) }
    
    {
      :code => 200,
      :body => ""
    }.each_pair { |meth, ret| @response.stub(meth) { ret } unless @response.respond_to?(meth) }
  end
end
