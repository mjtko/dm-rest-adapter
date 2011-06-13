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

      def resource_name(adapter, model)
        model.storage_name(adapter.name)
      end

      def resource_path(adapter, model, key = nil)
        path = "#{resource_name(adapter, model)}"
        path << "/#{key}"       if key
        path << ".#{extension}" if extension
        path
      end
      
      def format_as_string(resource)
        raise NotImplementedError,
          "#{self.class}#format_as_string not implemented"
      end
      
      def update_with_response(adapter, resource, body)
        raise NotImplementedError,
          "#{self.class}#update_with_response not implemented"
      end
      
      def parse_resources(adapter, body, model)
        raise NotImplementedError,
          "#{self.class}#parse_resources not implemented"
      end
      
      def parse_resource(adapter, body, model)
        raise NotImplementedError,
          "#{self.class}#parse_resource not implemented"
      end
    end
  end
end
