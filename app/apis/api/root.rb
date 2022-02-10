require "./app/apis/api/resources/v1/root.rb"

# これはapiディレクトリに対応したモジュール名
# たぶん複数のAPIを実装する場合はもっと具体的な名前になる
module API
    class Root < Grape::API
      # 接尾語を設定してる
      # http://localhost:3000/api/
      prefix 'api'

      mount Resources::V1::Root
      #mount Resources::V2::Root
    end
end
