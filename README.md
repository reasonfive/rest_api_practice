# README
booksテーブルと、そのCRUDを行うAPIの作成。

●booksテーブル
- id integer
- title(書籍名) string
- author(著者) string
- genre(ジャンル) string
- price(値段) integer
- enable(有効フラグ) boolean

●全件取得
　GET /api/v1/books
●著者名検索
　GET /api/v1/books/著者名
●新規登録
　POST /api/v1/books/new
●データ更新
　PUT /api/v1/books/update
●データ削除
　DELETE /api/v1/books/delete

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version 2.6.3

* Rails version Rails 5.2.3