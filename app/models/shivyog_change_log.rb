class ShivyogChangeLog < ApplicationRecord
  acts_as_paranoid

  belongs_to :change_loggable, polymorphic: true
  belongs_to :creator, class_name: 'User', foreign_key: :whodunnit

  validates :description, presence: true

  scope :change_loggable_id, lambda { |change_loggable_id| where(change_loggable_id: change_loggable_id) }
  scope :change_loggable_type, lambda { |change_loggable_type| where(change_loggable_type: change_loggable_type) }
  scope :attribute_name, lambda { |attribute_name| where(attribute_name: attribute_name) }

  before_create :assign_whodunnit

  def assign_whodunnit
    self.creator = $current_user
  end
end
