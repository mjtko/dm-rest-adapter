module DataMapperRest
  # TODO: Build JSON support

  class Adapter < DataMapper::Adapters::AbstractAdapter
    def create(resources)
      resources.each do |resource|
        model = resource.model

        response = @client[@format.resource_path(model)].post(
          @format.string_representation(resource),
          :content_type => @format.mime
        )

        @format.update_with_response(resource, response.body)
      end
    end

    def read(query)
      model = query.model

      records = if id = extract_id_from_query(query)
        response = @client[@format.resource_path(model, id)].get
        [ @format.parse_resource(response.body, model) ]
      else
        response = @client[@format.resource_path(model)].get(
          extract_params_from_query(query)
        )
        @format.parse_resources(response.body, model)
      end

      query.filter_records(records)
    end

    def update(dirty_attributes, collection)
      collection.select do |resource|
        model = resource.model
        key   = model.key
        id    = key.get(resource).join

        dirty_attributes.each { |p, v| p.set!(resource, v) }

        response = @client[@format.resource_path(model, id)].put(
          @format.string_representation(resource),
          :content_type => @format.mime
        )

        @format.update_with_response(resource, response.body)
      end.size
    end

    def delete(collection)
      collection.select do |resource|
        model = resource.model
        key   = model.key
        id    = key.get(resource).join
        
        response = @client[@format.resource_path(model, id)].delete

        (200..207).include?(response.code)
      end.size
    end

    private

    def initialize(*)
      super
      # FIXME: Instantiate the correct Format
      @format = Format::Xml.new(@options.merge(:repository_name => name))
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
  end
end
