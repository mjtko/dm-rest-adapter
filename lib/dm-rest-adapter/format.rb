module DataMapperRest
  module Format
    class AbstractFormat
  	  attr_accessor :extension, :mime, :repository_name

      def initialize(options = {})
        options = default_options.merge(options)
        @extension = options[:extension]
        @extension = nil if @extension == "" # consider blank extension as not present
        @mime = options[:mime]
        @repository_name = options.fetch(:repository_name, :default)
      end

      def default_options
        DataMapper::Mash.new
      end

      def resource_name(model)
        model.storage_name(repository_name)
      end

      def resource_path(*path_fragments)
        path = path_fragments.reduce("") do |memo, fragment|
          model = fragment[:model]
          key   = fragment[:key]
          memo << "#{resource_name(model)}/"
          memo << "#{key}/" if key
          memo
        end.chomp("/")
        
        if extension
          path + ".#{extension}"
        else
          path
        end
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