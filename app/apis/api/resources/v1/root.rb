require "./app/apis/api/resources/v1/books.rb"
module Resources
  module V1
    class Root < Grape::API
      version 'v1'
      format :json
      mount Resources::V1::Books
    end
  end
end
