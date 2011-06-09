require 'spec_helper'

describe DataMapperRest::Format do
  it "provides a MIME type derived from the format" do
    format = DataMapperRest::Format.new("json", nil)
    format.mime.should == "application/json"
  end
  
  it "provides an HTTP Content-Type header of the correct MIME type" do
  	format = DataMapperRest::Format.new("xml", nil)
    format.header.should == { "Content-Type" => "application/xml" }
  end
  
  it "use the extension specified to #initialize" do
    format = DataMapperRest::Format.new("xml", "plist")
    format.extension.should == "plist"
  end
  
  specify "extension may be nil" do
    format = DataMapperRest::Format.new("json", nil)
    format.extension.should be_nil
  end
  
  it "converts a blank extension to nil" do
    format = DataMapperRest::Format.new("json", "")
    format.extension.should be_nil
  end
end
