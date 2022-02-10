FactoryBot.define do

  factory :book do
    sequence(:title) { |n| "タイトル#{n}"}
    sequence(:author) { |n| "著者#{n}"}
    sequence(:genre) { |n| "ジャンル#{n}"}
    price {580}
  end

  factory :onepiece, class: Book do
    sequence(:title) { |n| "ONE PIECE #{n}"}
    author { '尾田栄一郎' }
    genre { '漫画' }
    price { 480 }
  end

end
