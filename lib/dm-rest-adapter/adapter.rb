module DataMapperRest
  # TODO: Follow redirects to newly created resources (existing bug)
  #       Specs for parse errors (existing bug)
  #       Allow HTTP scheme to be specified in options (i.e. allow HTTPS) (existing bug)
  #       Allow nested resources (existing bug)
  #       Map properties to field names for #create/#update instead of assuming they match (existing bug)
  #       Specs for associations (existing bug)

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
        id    = key.get(resource).join
        
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
        id    = key.get(resource).join
        
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
    
    def extract_parent_items_from_resource(resource)
      model = resource.model
      
      return [] unless model.relationships.any? { |relationship| relationship.inverse.options[:nested] }
      
      # FIXME: This is far too hacky. Change it.
      model.relationships.collect do |relationship|
        if relationship.inverse.options[:nested]
          if relationship.loaded?(resource)
            # TODO: Recursively walk back up the tree
            break [ { :model => relationship.target_model, :key => relationship.source_key.get(resource).join } ]
          end
        end
      end.compact
    end
    
    def extract_parent_items_from_query(query)
      model = query.model
      conditions = query.conditions
      
      return [] unless conditions.kind_of?(DataMapper::Query::Conditions::AndOperation)
      
      conditions.collect do |operand|
        if operand.kind_of?(DataMapper::Query::Conditions::EqualToComparison)
          if operand.relationship? && !operand.subject.target_model.eql?(model)
            relationship = operand.subject
            if relationship.inverse.options[:nested]
              {
                :model => relationship.target_model,
                :key => relationship.target_key.get(operand.value).join
              }.reject { |key, value| DataMapper::Ext.blank?(value) }
            end
          end
        end
      end.compact
    end

    def extract_params_from_query(query)
      model = query.model
      conditions = query.conditions

      return {} unless conditions.kind_of?(DataMapper::Query::Conditions::AndOperation)
      return {} if conditions.any? { |o| o.subject.key? }
      
      query.options.reject do |k, v|
        [:fields, :conditions].include?(k)
      end.merge(extract_params_from_conditions(conditions))
    end
    
    def extract_params_from_conditions(conditions)
      params = conditions.collect do |operand|
        if operand.kind_of?(DataMapper::Query::Conditions::EqualToComparison)
          if operand.relationship? && !operand.subject.inverse.options[:nested]
            mapping = operand.foreign_key_mapping
            { mapping.subject.field => mapping.value }
          end
        end
      end
      
      params.compact.reduce({}) { |memo, v| memo.merge(v) }
    end
  end
end
