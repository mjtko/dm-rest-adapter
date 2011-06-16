require 'spec_helper'

shared_examples_for 'a Format' do
  describe "uncustomized" do
    subject { described_class.new }

    its(:mime) { should == default_mime }
    its(:extension) { should == default_extension }

    it "appends the default extension to the resource path" do
      subject.resource_path(Book).should == "books.#{default_extension}"
    end
  end

  describe "custom extension" do
    subject { described_class.new(:extension => "data") }

    its(:extension) { should == "data" }

    it "appends the extension to the resource path" do
      subject.resource_path(Book).should == "books.data"
    end
  end

  describe "no extension" do
    subject { described_class.new(:extension => nil) }

    its(:extension) { should be_nil }

    it "does not append an extension to the resource path" do
      subject.resource_path(Book).should == "books"
    end
  end

  describe "empty extension" do
    subject { described_class.new(:extension => "") }

    its(:extension) { should be_nil }

    it "does not append an extension to the resource path" do
      subject.resource_path(Book).should == "books"
    end
  end
end
