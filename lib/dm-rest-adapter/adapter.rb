module DataMapperRest
  # TODO: Follow redirects to newly created resources (existing bug)
  #       Specs for resource format parse errors (existing bug)
  #       Map properties to field names for #create/#update instead of assuming they match (existing bug)

  class Adapter < DataMapper::Adapters::AbstractAdapter
    attr_accessor :rest_client
    
    def create(resources)
      resources.each do |resource|
        model = resource.model
        
        path_items = extract_parent_items_from_resource(resource)
        path_items << { :model => model }
        
        response = @rest_client[@format.resource_path(*path_items)].post(
          @format.string_representation(resource),
          :content_type => @format.mime, :accept => @format.mime
        )

        @format.update_attributes(resource, response.body)
      end
    end

    def read(query)
      model = query.model

      path_items = extract_parent_items_from_query(query)
      
      records = if id = extract_id_from_query(query)
        begin
          path_items << { :model => model, :key => id }
          response = @rest_client[@format.resource_path(*path_items)].get(
            :accept => @format.mime
          )
          [ @format.parse_record(response.body, model) ]
        rescue RestClient::ResourceNotFound
          []
        end
      else
        path_items << { :model => model }
        query_options = {
          :params => extract_params_from_query(query),
          :accept => @format.mime
        }
        query_options.delete(:params) if query_options[:params].empty?
        
        response = @rest_client[@format.resource_path(*path_items)].get(
          query_options
        )
        @format.parse_collection(response.body, model)
      end

      query.filter_records(records)
    end

    def update(dirty_attributes, collection)
      collection.select do |resource|
        model = resource.model
        key   = model.key
        id    = key.get(resource).first
        
        path_items = extract_parent_items_from_resource(resource)
        path_items << { :model => model, :key => id }

        dirty_attributes.each { |p, v| p.set!(resource, v) }

        response = @rest_client[@format.resource_path(*path_items)].put(
          @format.string_representation(resource),
          :content_type => @format.mime, :accept => @format.mime
        )

        @format.update_attributes(resource, response.body)
      end.size
    end

    def delete(collection)
      collection.select do |resource|
        model = resource.model
        key   = model.key
        id    = key.get(resource).first
        
        path_items = extract_parent_items_from_resource(resource)
        path_items << { :model => model, :key => id }
        
        response = @rest_client[@format.resource_path(*path_items)].delete(
          :accept => @format.mime
        )

        (200..207).include?(response.code)
      end.size
    end

    private

    def initialize(*)
      super
      
      raise ArgumentError, "Missing :format in @options" unless @options[:format]
      
      case @options[:format]
        when "xml"
          @format = Format::Xml.new(@options.merge(:repository_name => name))
        when "json"
          @format = Format::Json.new(@options.merge(:repository_name => name))
        else
          @format = @options[:format]
      end
      
      @rest_client = RestClient::Resource.new(normalized_uri)
    end

    def normalized_uri
      @normalized_uri ||=
        begin
          query = @options.except(:adapter, :scheme, :user, :password, :host, :port, :path, :fragment)
          query = nil if query.empty?

          Addressable::URI.new(
            :scheme       => @options[:scheme] || "http",
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
    
    # Note that ManyToOne denotes the child end of a 'has 1' or a 'has n' relationship
    def extract_parent_items_from_resource(resource)
      model = resource.model
      
      nested_relationship = model.relationships.detect do |relationship|
        relationship.kind_of?(DataMapper::Associations::ManyToOne::Relationship) &&
          relationship.inverse.options[:nested]
      end
      
      return [] unless nested_relationship
      
      path_items = if nested_relationship.loaded?(resource)
        extract_parent_items_from_resource(nested_relationship.get(resource))
      else
        []
      end
      
      path_items << {
        :model => nested_relationship.target_model,
        :key => nested_relationship.source_key.get(resource).first
      }.reject { |key, value| value.nil? }
    end
    
    # Note that ManyToOne denotes the child end of a 'has 1' or a 'has n' relationship
    def extract_parent_items_from_query(query)
      model = query.model
      conditions = query.conditions
      
      return [] unless conditions.kind_of?(DataMapper::Query::Conditions::AndOperation)
      
      nested_relationship_operand = conditions.detect do |operand|
        operand.kind_of?(DataMapper::Query::Conditions::EqualToComparison) &&
          operand.relationship? &&
          operand.subject.kind_of?(DataMapper::Associations::ManyToOne::Relationship) &&
          operand.subject.inverse.options[:nested]
      end
      
      return [] unless nested_relationship_operand
      
      nested_relationship = nested_relationship_operand.subject
      
      extract_parent_items_from_resource(nested_relationship_operand.value) << {
        :model => nested_relationship.target_model,
        :key => nested_relationship.target_key.get(nested_relationship_operand.value).first
      }.reject { |key, value| value.nil? }
    end

    def extract_params_from_query(query)
      model = query.model
      conditions = query.conditions

      return {} unless conditions.kind_of?(DataMapper::Query::Conditions::AndOperation)
      return {} if conditions.any? { |o| o.subject.key? }
      
      query.options.reject { |k, v| [:fields, :conditions].include?(k) } \
        .merge(extract_params_from_conditions(conditions))
    end
    
    def extract_params_from_conditions(conditions)
      params = conditions.collect do |operand|
        if operand.kind_of?(DataMapper::Query::Conditions::EqualToComparison)
          if operand.relationship? && !operand.subject.inverse.options[:nested]
            mapping = operand.foreign_key_mapping
            { mapping.subject.field.to_sym => mapping.value }
          end
        end
      end
      
      params.compact.reduce({}) { |memo, v| memo.merge(v) }
    end
  end
end
