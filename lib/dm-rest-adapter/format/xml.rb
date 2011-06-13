module DataMapperRest
  module Format
    class Xml < AbstractFormat
      def default_options
        { :mime => "application/xml", :extension => "xml" }
      end
    end
  end
end
