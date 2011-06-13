module DataMapperRest
  module Format
    class Xml < AbstractFormat
      def default_options
        { :mime => "application/xml", :extension => "xml" }
      end
      
      def formatted(resource)
        resource.to_xml
      end
      
      def update_with_response(adapter, resource, body)
        return if DataMapper::Ext.blank?(body)

        model      = resource.model
        properties = model.properties(adapter.name)

        parse_resource(adapter, body, model).each do |key, value|
          if property = properties[key.to_sym]
            property.set!(resource, value)
          end
        end
      end
      
      def parse_resources(adapter, xml, model)
        doc = REXML::Document::new(xml)

        field_to_property = Hash[ model.properties(adapter.name).map { |p| [ p.field, p ] } ]
        element_name      = element_name(adapter, model)

        doc.elements.collect("/#{resource_name(adapter, model)}/#{element_name}") do |entity_element|
          record_from_rexml(entity_element, field_to_property)
        end
      end
      
      def parse_resource(adapter, xml, model)
        doc = REXML::Document::new(xml)

        element_name = element_name(adapter, model)

        unless entity_element = REXML::XPath.first(doc, "/#{element_name}")
          raise "No root element matching #{element_name} in xml"
        end

        field_to_property = Hash[ model.properties(adapter.name).map { |p| [ p.field, p ] } ]
        record_from_rexml(entity_element, field_to_property)
      end

      private
      
      def record_from_rexml(entity_element, field_to_property)
        record = {}

        entity_element.elements.map do |element|
          # TODO: push this to the per-property mix-in for this adapter
          field = element.name.to_s.tr('-', '_')
          next unless property = field_to_property[field]
          record[field] = property.typecast(element.text)
        end

        record
      end

      def element_name(adapter, model)
        DataMapper::Inflector.singularize(model.storage_name(adapter.name))
      end
    end
  end
end
