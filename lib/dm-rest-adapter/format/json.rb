require 'multi_json'

module DataMapperRest
  module Format
    class Json < AbstractFormat
      def default_options
        DataMapper::Mash.new({ :mime => "application/json", :extension => "json" })
      end
      
      def string_representation(resource)
        model = resource.model
        hash  = {}
        
        hash = model.properties.reduce(hash) do |h, property|
          h.merge(property.field.to_sym => property.dump(property.get(resource)))
        end
        
        hash = model.relationships.reject{ |r| r.source_key == model.key }.reduce(hash) do |h, relationship|
          keys_hash = relationship.source_key.reduce({}) do |kh, key|
            kh.merge(key.field.to_sym => key.dump(key.get(resource)))
          end
          h.merge(keys_hash)
        end
        
        MultiJson.encode(hash)
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
