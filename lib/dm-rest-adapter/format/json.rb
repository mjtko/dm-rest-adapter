module DataMapperRest
  module Format
    class Json < AbstractFormat
      def default_options
        DataMapper::Mash.new({ :mime => "application/json", :extension => "json" })
      end
      
      def string_representation(resource)
        resource.to_json
      end
      
      def update_attributes(resource, body)
        return if DataMapper::Ext.blank?(body)

        model      = resource.model
        properties = model.properties(repository_name)

        parse_record(body, model).each do |key, value|
          if property = properties[key.to_sym]
            property.set!(resource, value)
          end
        end
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
