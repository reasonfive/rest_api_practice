require "rails_helper"
require "uri"

RSpec.describe "Books", type: :request do
  let(:post_api) { post "/api/v1/books/create", params: @params }

  describe "POST /books/create", type: :api do
    context "入力が正常値の場合" do
      before do
        @params = {
          title: "題名",
          author: "著者",
          genre: "ジャンル",
          price: 480
        }
        post_api
        @response_json = JSON.parse(response.body)
      end
      it 'ステータスコード:201であること' do
        expect(response).to have_http_status(201)
      end
      it 'titleが題名であること' do
        expect(@response_json["title"]).to eq("題名")
      end
      it 'authorが著者であること' do
        expect(@response_json["author"]).to eq("著者")
      end
      it 'genreがジャンルであること' do
        expect(@response_json["genre"]).to eq("ジャンル")
      end
      it 'priceが480であること' do
        expect(@response_json["price"]).to eq(480)
      end
    end
    context "題名が５０文字を超える場合" do
      before do
        @params = {
          title: "0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789A",
          author: "著者",
          genre: "ジャンル",
          price: 400
        }
        post_api
        @response_json = JSON.parse(response.body)
      end
      it 'ステータスコード:400であること' do
        expect(response).to have_http_status(400)
      end
      it "エラーが返却されること" do
        expect(@response_json["error"]).to eq("題名は50文字以内で入力して下さい")
      end
    end
    context "値段がIntegerでない場合" do
      before do
        @params = {
          title: "題名",
          author: "著者",
          genre: "ジャンル",
          price: "400あ"
        }
        post_api
        @response_json = JSON.parse(response.body)
      end
      it 'ステータスコード:400であること' do
        expect(response).to have_http_status(400)
      end
      it "エラーが返却されること" do
        expect(@response_json["error"]).to eq("price is invalid")
      end
    end
  end

  describe "GET /books" do
    context "有効なデータが存在しない場合" do
      before do
        get "/api/v1/books/"
        @response_json = JSON.parse(response.body)
      end
      it 'ステータスコード:200であること' do
        expect(response).to have_http_status(200)
      end
      it "空のデータが返ってくること" do
        expect(@response_json.length).to eq(0)
      end
    end
    context "データが10件存在する場合" do
      before do
        FactoryBot.create_list(:book, 10)
        get "/api/v1/books/"
        @response_json = JSON.parse(response.body)
      end
      it 'ステータスコード:200であること' do
        expect(response).to have_http_status(200)
      end
      it "データが10件取得できること" do
        expect(@response_json.length).to eq(10)
      end
    end
  end

  describe "GET /books/{:author}" do
    before do
      FactoryBot.create_list(:book, 10)
      FactoryBot.create_list(:onepiece, 3)
    end
    context "該当する著者が存在しない場合" do
      before do
        get "/api/v1/books/#{URI.encode "尾田栄一郎Z"}"
        @response_json = JSON.parse(response.body)
      end
      it 'ステータスコード:200であること' do
        expect(response).to have_http_status(200)
      end
      it "空のデータが返ってくること" do
        expect(@response_json.length).to eq(0)
      end
    end
    context "該当する著者が存在する場合" do
      before do
        get "/api/v1/books/#{URI.encode "尾田栄一郎"}"
        @response_json = JSON.parse(response.body)
      end
      it 'ステータスコード:200であること' do
        expect(response).to have_http_status(200)
      end
      it "データが取得できること" do
        expect(@response_json.length).to eq(3)
      end
    end
  end

  describe "PUT /books/update" do
    before do
      @params = {
        title: "題名",
        author: "著者",
        genre: "ジャンル",
        price: 480
      }
      post_api
      json = JSON.parse(response.body)
      @target_id = json["id"]
    end
    context "入力が正常値の場合" do
      before do
        params = {
          id: @target_id,
          title: "改名",
          author: "著者X",
          genre: "新ジャンル",
          price: 480000
        }
        put "/api/v1/books/update", params: params
        @response1 = response

        get "/api/v1/books/#{URI.encode "著者X"}"

        @response2_json = JSON.parse(response.body)
      end
      it 'ステータスコード:200であること' do
        expect(response).to have_http_status(200)
      end
      it "trueが返却されること" do
        expect(@response1.body).to eq("true")
      end
      it 'ステータスコード:200であること' do
        expect(response).to have_http_status(200)
      end
      it '当該データが１件存在すること' do
        expect(@response2_json.length).to eq(1)
        expect(@response2_json[0]["id"]).to eq(@target_id)
      end
      it 'titleが改名に更新されていること' do
        expect(@response2_json[0]["title"]).to eq("改名")
      end
      it 'authorが著者Xに更新されていること' do
        expect(@response2_json[0]["author"]).to eq("著者X")
      end
      it 'genreが新ジャンルに更新されていること' do
        expect(@response2_json[0]["genre"]).to eq("新ジャンル")
      end
      it 'priceが480000に更新されていること' do
        expect(@response2_json[0]["price"]).to eq(480000)
      end
    end
    context "存在しないIDの場合" do
      before do
        params = {
          id: 9999,
          title: "改名",
          author: "著者X",
          genre: "新ジャンル",
          price: 480000
        }
        put "/api/v1/books/update", params: params
      end
      it 'ステータスコード:200であること' do
        expect(response).to have_http_status(200)
      end
      it "falseが返却されること" do
        expect(response.body).to eq("false")
      end
    end
    context "削除済みの場合" do
      before do
        params = {
          id: @target_id,
        }
        patch "/api/v1/books/delete", params: params

        params = {
          id: @target_id,
          title: "改名",
          author: "著者X",
          genre: "新ジャンル",
          price: 480000
        }
        put "/api/v1/books/update", params: params
      end
      it 'ステータスコード:200であること' do
        expect(response).to have_http_status(200)
      end
      it "falseが返却されること" do
        expect(response.body).to eq("false")
      end
    end
    context "題名が５０文字を超える場合" do
      before do
        params = {
          id: @target_id,
          title: "0123456789ABCDEFGHIJ0123456789ABCDEFGHIJ0123456789A",
          author: "著者X",
          genre: "新ジャンル",
          price: 480000
        }
        put "/api/v1/books/update", params: params
        @response_json = JSON.parse(response.body)
      end
      it 'ステータスコード:400であること' do
        expect(response).to have_http_status(400)
      end
      it "エラーが返却されること" do
        expect(@response_json["error"]).to eq("題名は50文字以内で入力して下さい")
      end
    end
    context "値段がIntegerでない場合" do
      before do
        params = {
          title: "題名",
          author: "著者X",
          genre: "新ジャンル",
          price: "480000あ"
        }
        put "/api/v1/books/update", params: params
        @response_json = JSON.parse(response.body)
      end
      it 'ステータスコード:400であること' do
        expect(response).to have_http_status(400)
      end
      it "エラーが返却されること" do
        expect(@response_json["error"]).to eq("price is invalid")
      end
    end
  end

  describe "PATCH /books/delete" do
    before do
      @params = {
        title: "題名",
        author: "著者",
        genre: "ジャンル",
        price: 480
      }
      post_api
      response1_json = JSON.parse(response.body)
      @target_id = response1_json["id"]
      get "/api/v1/books/"
      @response2_json = JSON.parse(response.body)
    end
    it "データが登録されていること" do
      expect(@response2_json.length).to eq(1)
      expect(@response2_json[0]["title"]).to eq("題名")
      expect(@response2_json[0]["author"]).to eq("著者")
      expect(@response2_json[0]["genre"]).to eq("ジャンル")
      expect(@response2_json[0]["price"]).to eq(480)
    end
    context "入力が正常値の場合" do
      before do
        params = {
          id: @target_id
        }
        patch "/api/v1/books/delete", params: params
        @response1 = response

        get "/api/v1/books/"
        @response2_json = JSON.parse(response.body)
      end
      it "正常に終了すること" do
        expect(@response1).to have_http_status(200)
        expect(@response1.body).to eq("true")
      end
      it "正常に削除できていること" do
        expect(@response2_json.length).to eq(0)
      end
    end
    context "存在しないIDの場合" do
      before do
        params = {
          id: 9999,
        }
        patch "/api/v1/books/delete", params: params
      end
      it "falseが返却されること" do
        expect(response).to have_http_status(200)
        expect(response.body).to eq("false")
      end
    end
    context "削除済みの場合" do
      before do
        params = {
          id: @target_id,
        }
        patch "/api/v1/books/delete", params: params
        params = {
          id: @target_id,
        }
        patch "/api/v1/books/delete", params: params
      end
      it "falseが返却されること" do
        expect(response).to have_http_status(200)
        expect(response.body).to eq("false")
      end
    end
  end
end
