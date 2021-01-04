class CreateForumRequest < ApplicationRecord
  validates :name, :no_of_people, :about_forum, :description, :motive, presence: true
  belongs_to :user
end
