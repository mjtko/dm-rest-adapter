class Chapter
  include DataMapper::Resource
  
  property :id,                Serial
  property :difficult_book_id, Integer, :field => 'book_id'
  
  belongs_to :book, 'DifficultBook'
end
