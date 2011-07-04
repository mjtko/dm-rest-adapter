class Vendor
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String
  
  belongs_to :book, 'DifficultBook', :child_key => ['book_id']
end
