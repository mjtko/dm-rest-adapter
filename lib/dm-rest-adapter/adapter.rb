module DataMapperRest
  # TODO: Follow redirects to newly created resources (existing bug)
  #       Specs for parse errors (existing bug)
  #       Allow HTTP scheme to be specified in options (i.e. allow HTTPS) (existing bug)
  #       Allow nested resources (existing bug)
  #       Map properties to field names for #create/#update instead of assuming they match (existing bug)
  #       Specs for associations (existing bug)
  #       Rewrite rest_adapter_spec.rb to use a test-specific adapter (avoid test duplication)
  #       Specify Accept: header in the request, to allow content-type negotiation on the server.

  class Adapter < DataMapper::Adapters::AbstractAdapter
    attr_accessor :rest_client
    
    def create(resources)
      resources.each do |resource|
        model = resource.model

        response = @rest_client[@format.resource_path(model)].post(
          @format.string_representation(resource),
          :content_type => @format.mime
        )

        @format.update_attributes(resource, response.body)
      end
    end

    def read(query)
      model = query.model

      records = if id = extract_id_from_query(query)
        begin
          response = @rest_client[@format.resource_path(model, id)].get
          [ @format.parse_record(response.body, model) ]
        rescue RestClient::ResourceNotFound
          []
        end
      else
        response = @rest_client[@format.resource_path(model)].get(
          :params => extract_params_from_query(query)
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

        dirty_attributes.each { |p, v| p.set!(resource, v) }

        response = @rest_client[@format.resource_path(model, id)].put(
          @format.string_representation(resource),
          :content_type => @format.mime
        )

        @format.update_attributes(resource, response.body)
      end.size
    end

    def delete(collection)
      collection.select do |resource|
        model = resource.model
        key   = model.key
        id    = key.get(resource).join
        
        response = @rest_client[@format.resource_path(model, id)].delete

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

    def extract_params_from_query(query)
      conditions = query.conditions

      return {} unless conditions.kind_of?(DataMapper::Query::Conditions::AndOperation)
      return {} if conditions.any? { |o| o.subject.key? }

      query.options
    end
  end
end
