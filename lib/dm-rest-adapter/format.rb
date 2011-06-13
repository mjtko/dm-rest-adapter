module DataMapperRest
  module Format
    class AbstractFormat
  	  attr_accessor :extension, :mime, :repository_name

      def initialize(options = {})
        options = default_options.merge(options)
        @extension = options[:extension]
        @extension = nil if extension == "" # consider blank extension as not present
        @mime = options[:mime]
        @repository_name = options.fetch(:repository_name, :default)
      end

      def header
        { "Content-Type" => @mime }
      end

      def default_options
        {}
      end

      def resource_name(model)
        model.storage_name(repository_name)
      end

      def resource_path(model, key = nil)
        path = "#{resource_name(model)}"
        path << "/#{key}"       if key
        path << ".#{extension}" if extension
        path
      end
      
      def format_as_string(resource)
        raise NotImplementedError,
          "#{self.class}#format_as_string not implemented"
      end
      
      def update_with_response(resource, body)
        raise NotImplementedError,
          "#{self.class}#update_with_response not implemented"
      end
      
      def parse_resources(body, model)
        raise NotImplementedError,
          "#{self.class}#parse_resources not implemented"
      end
      
      def parse_resource(body, model)
        raise NotImplementedError,
          "#{self.class}#parse_resource not implemented"
      end
    end
  end
end
