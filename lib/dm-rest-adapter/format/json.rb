module DataMapperRest
  module Format
    class Json < AbstractFormat
      def default_options
        DataMapper::Mash.new({ :mime => "application/json", :extension => "json" })
      end
      
      def string_representation(resource)
        resource.to_json(:raw => true)
      end
      
      def parse_record(json, model)
        hash = JSON.parse(json)
        field_to_property = Hash[ model.properties(repository_name).map { |p| [ p.field, p ] } ]
        record_from_hash(hash, field_to_property)
      end
      
      def parse_collection(json, model)
        array = JSON.parse(json)
        field_to_property = Hash[ model.properties(repository_name).map { |p| [ p.field, p ] } ]
        array.collect do |hash|
          record_from_hash(hash, field_to_property)
        end
      end
      
      private
      
      def resource_as_hash(resource)
        resource.model.properties.reduce({}) do |hash, property|
          hash.merge({ property.field => property.dump(resource.__send__(property.name)) })
        end
      end
      
      def record_from_hash(hash, field_to_property)
        record = {}
        hash.each_pair do |field, value|
          next unless property = field_to_property[field]
          record[field] = property.typecast(value)
        end
        
        record
      end
    end
  end
end
