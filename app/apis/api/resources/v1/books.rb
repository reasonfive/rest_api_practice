require './app/apis/api/resources/v1/error_msg_constants.rb'

module Resources
  module V1
    class Books < Root
      helpers do
        def title_length_check title
          error!(ErrorMsgConstants::TitleLengthError, 400) if title.length > 50
        end
      end
      resource :books do

        # GET /api/v1/books
        desc 'Return all enable books'
        get do
          present Book.active, with: Entities::V1::BookEntity
        end

        # GET /api/v1/books/{:author}
        desc 'Return books.'
        params do
          requires :author, type: String, desc: 'Author name.'
        end
        get ':author' do
          #これだと最初の１件だけ
          # Book.find_by(author: params[:author])

          #こっちだと合致するもの全件
          present Book.any_author(params[:author]), with: Entities::V1::BookEntity
        end

        # POST /api/v1/books/create
        desc 'Create books.'
        params do
          optional :title, type: String
          optional :author, type: String
          optional :price, type: Integer
          optional :genre, type: String
        end
        post 'create' do
          title_length_check params[:title]
          present @book = Book.create(title: params[:title], author: params[:author], price: params[:price], genre: params[:genre]), with: Entities::V1::BookEntity
        end

        desc 'Update a book.'
        params do
          optional :id, type: Integer
          optional :title, type: String
          optional :author, type: String
          optional :price, type: Integer
          optional :genre, type: String
        end
        put 'update' do
          title_length_check (params[:title])
          @book = Book.find_by(id: params[:id])

          return false if @book == nil || @book.enable == false

          @book.title = (params[:title])
          @book.author = (params[:author])
          @book.price = (params[:price])
          @book.genre = (params[:genre])

          @book.save
        end


        # PATCH /api/v1/books/delete
        desc 'Delete a book'
        params do
          optional :id, type: Integer
        end
        patch 'delete' do
          @book = Book.find_by(id: params[:id])
          return false if @book == nil || @book.enable == false

          @book.enable = false

          @book.save
        end

      end
    end
  end
end
