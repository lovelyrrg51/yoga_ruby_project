class GlobalPreference < ApplicationRecord
  default_scope { where(is_deleted: false) }

  validates :key, uniqueness: true

  scope :key, ->(key) { where(key: key) }

  enum input_type: {
    text_field: 0,
    text_area: 1,
    tagsinput: 2,
    check_box: 3
  }
  enum group_name: {
    Event: 0,
    SadhakProfile: 1,
    SyClub: 2
  }

  # Method to get value of key
  def self.get_value_of(key)
    unscoped.find_by(key: key)&.val
  end

  # Method to set value.
  def self.set_value_of(key,val)
    gp = unscoped.where(key: key).first_or_create
    gp.update_attribute(:val, val)
  end

end

