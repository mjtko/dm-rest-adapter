class BookCover
  include DataMapper::Resource
  
  property :id,                Serial
  property :difficult_book_id, Integer, :field => 'book_id'
  
  belongs_to :difficult_book
end
