module DataMapperRest
  # TODO: Abstract XML support out from the protocol
  # TODO: Build JSON support

  class Adapter < DataMapper::Adapters::AbstractAdapter
    def create(resources)
      resources.each do |resource|
        model = resource.model

        response = @client[@format.resource_path(resource_name(model))].post(
          resource.to_xml,
          :content_type => @format.mime
        )

        update_with_response(resource, response)
      end
    end

    def read(query)
      model = query.model

      records = if id = extract_id_from_query(query)
        response = @client[@format.resource_path(resource_name(model), id)].get
        [ parse_resource(response.body, model) ]
      else
        response = @client[@format.resource_path(resource_name(model))].get(
          extract_params_from_query(query)
        )
        parse_resources(response.body, model)
      end

      query.filter_records(records)
    end

    def update(dirty_attributes, collection)
      collection.select do |resource|
        model = resource.model
        key   = model.key
        id    = key.get(resource).join

        dirty_attributes.each { |p, v| p.set!(resource, v) }

        response = @client[@format.resource_path(resource_name(model), id)].put(
          resource.to_xml,
          :content_type => @format.mime
        )

        update_with_response(resource, response)
      end.size
    end

    def delete(collection)
      collection.select do |resource|
        model = resource.model
        key   = model.key
        id    = key.get(resource).join
        
        response = @client[@format.resource_path(resource_name(model), id)].delete

        (200..207).include?(response.code)
      end.size
    end

    private

    def initialize(*)
      super
      @format = Format::Xml.new
      @client = RestClient::Resource.new(normalized_uri)
    end

    def normalized_uri
      @normalized_uri ||=
        begin
          query = @options.except(:adapter, :user, :password, :host, :port, :path, :fragment)
          query = nil if query.empty?

          Addressable::URI.new(
            :scheme       => "http",
            :user         => @options[:user],
            :password     => @options[:password],
            :host         => @options[:host],
            :port         => @options[:port],
            :path         => @options[:path],
            :query_values => query,
            :fragment     => @options[:fragment]
          )
        end
    end

    def extract_id_from_query(query)
      return nil unless query.limit == 1

      conditions = query.conditions

      return nil unless conditions.kind_of?(DataMapper::Query::Conditions::AndOperation)
      return nil unless (key_condition = conditions.select { |o| o.subject.key? }).size == 1

      key_condition.first.value
    end

    def extract_params_from_query(query)
      conditions = query.conditions

      return {} unless conditions.kind_of?(DataMapper::Query::Conditions::AndOperation)
      return {} if conditions.any? { |o| o.subject.key? }

      query.options
    end

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

    def parse_resource(xml, model)
      doc = REXML::Document::new(xml)

      element_name = element_name(model)

      unless entity_element = REXML::XPath.first(doc, "/#{element_name}")
        raise "No root element matching #{element_name} in xml"
      end

      field_to_property = Hash[ model.properties(name).map { |p| [ p.field, p ] } ]
      record_from_rexml(entity_element, field_to_property)
    end

    def parse_resources(xml, model)
      doc = REXML::Document::new(xml)

      field_to_property = Hash[ model.properties(name).map { |p| [ p.field, p ] } ]
      element_name      = element_name(model)

      doc.elements.collect("/#{resource_name(model)}/#{element_name}") do |entity_element|
        record_from_rexml(entity_element, field_to_property)
      end
    end

    def element_name(model)
      DataMapper::Inflector.singularize(model.storage_name(self.name))
    end

    def resource_name(model)
      model.storage_name(self.name)
    end

    def update_with_response(resource, response)
      return unless (200..207).include?(response.code) && !DataMapper::Ext.blank?(response.body)

      model      = resource.model
      properties = model.properties(name)

      parse_resource(response.body, model).each do |key, value|
        if property = properties[key.to_sym]
          property.set!(resource, value)
        end
      end
    end
  end
end
