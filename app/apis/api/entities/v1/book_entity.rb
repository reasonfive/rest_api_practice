module Entities
  module V1
    class BookEntity < RootEntity
      expose :id, :title, :author, :price, :genre
    end
  end
end
