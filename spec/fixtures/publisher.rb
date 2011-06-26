class Publisher
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime
  property :name,       String
  
  has n, :books, 'DifficultBook'
end
