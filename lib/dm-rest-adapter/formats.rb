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
        path = if key
          "#{resource_name(adapter, model)}/#{key}"
        else
           "#{resource_name(adapter, model)}"
        end
        
        if @extension
          "#{path}.#{@extension}"
        else
          path
        end
      end
      
      def update_with_response(adapter, resource, body)
        raise NotImplementedError, "#{self.class}#update_with_response not implemented"
      end
    end
  end
end
