class UserRole < ApplicationRecord
  acts_as_paranoid

  belongs_to :role
  belongs_to :user
  belongs_to :last_updated_by, class_name: 'User', foreign_key: :whodunnit
  has_many :role_dependencies, dependent: :destroy

  before_save :set_whodunnit

  def set_whodunnit
    self.last_updated_by = $current_user
  end
end
