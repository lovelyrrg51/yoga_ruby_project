class RoleDependency < ApplicationRecord
  acts_as_paranoid

  attr_reader :syid, :first_name, :role

  belongs_to :role_dependable, polymorphic: true
  belongs_to :user_role
  belongs_to :last_updated_by, class_name: 'User', foreign_key: :whodunnit
  has_one :user, through: :user_role
  has_one :role, through: :user_role
  has_one :sadhak_profile, through: :user

  delegate :syid, to: :sadhak_profile, allow_nil: true
  delegate :first_name, to: :sadhak_profile, allow_nil: true

  scope :event_id, ->(event_id) do
    where(role_dependable_type: 'Event', role_dependable_id: event_id)
  end

  scope :role, ->(role) do
    joins(user_role: [:role])
      .where(roles: { name: role.to_s.split(',').map(&:downcase) })
  end

  validates :user_role_id, presence: true,
    uniqueness: { scope: [:role_dependable_type, :role_dependable_id]}

  before_save :set_whodunnit, :set_is_restriction

  private

  def set_whodunnit
    self.last_updated_by = $current_user
  end

  def set_is_restriction
    self.is_restriction = self.start_date.present? && self.end_date.present?
  end

end
