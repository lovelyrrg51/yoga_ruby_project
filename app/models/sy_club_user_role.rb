class SyClubUserRole < ApplicationRecord
  validates :role_name, presence: true, length: { minimum: 3 }
end
