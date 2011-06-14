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
      
      def string_representation(resource)
        raise NotImplementedError,
          "#{self.class}#string_representation not implemented"
      end
      
      def update_attributes(resource, body)
        raise NotImplementedError,
          "#{self.class}#update_attributes not implemented"
      end
      
      def parse_collection(body, model)
        raise NotImplementedError,
          "#{self.class}#parse_collection not implemented"
      end
      
      def parse_record(body, model)
        raise NotImplementedError,
          "#{self.class}#parse_record not implemented"
      end
    end
  end
end
