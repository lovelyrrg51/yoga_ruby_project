class Teacher < ApplicationRecord
  validates :first_name, :last_name, :email, :title, :bio, presence: true
end
