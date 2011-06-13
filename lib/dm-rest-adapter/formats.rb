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

      def default_options
        {}
      end

      def resource_path(name, key = nil)
        path = if key
          "#{name}/#{key}"
        else
          name
        end
        
        if @extension
          "#{path}.#{@extension}"
        else
          path
        end
      end
    end
  end
end
