class Comment < ApplicationRecord
  validates :name, :email, :comment, presence: true
  belongs_to :post
end
