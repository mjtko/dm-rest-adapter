module DataMapperRest
  module Format
    class AbstractFormat
  	  attr_accessor :extension, :mime

      def initialize(options = {})
        @extension = options.fetch(:extension, default_options[:extension])
        @extension = nil if extension == "" # consider blank extension as not present
        @mime = options.fetch(:mime, default_options[:mime])
      end

      def header
        { "Content-Type" => @mime }
      end
    end
  end
end
