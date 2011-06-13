module DataMapperRest
  module Format
    class Json < AbstractFormat
      def default_options
        { :mime => "application/json", :extension => "json" }
      end
    end
  end
end
