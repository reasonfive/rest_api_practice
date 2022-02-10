class Book < ApplicationRecord
  scope :active, -> { where(enable: true) }
  scope :any_author, -> (author) { where(enable: true, author: author) }
end
