class Role < ApplicationRecord
  include AASM

  acts_as_paranoid

  has_many :user_roles
  has_many :users, through: :user_roles
  belongs_to :last_updated_by, class_name: 'User', foreign_key: :whodunnit
  before_save { |role| role.name = name.downcase }
  before_save :set_whodunnit

  validates :name, presence: true, length: { maximum: 140 }, uniqueness: { case_sensitive: false }
  validates :description, presence: true, length: { maximum: 250 }
  validates :role_type, presence: true

  enum role_type: {
    independent: 0,
    dependent: 1
  }

  aasm column: :role_type, enum: true, whiny_transitions: false do
    state :independent, initial: true
    state :dependent
  end

  def set_whodunnit
    self.last_updated_by = $current_user
  end
end
