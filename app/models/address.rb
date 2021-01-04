 class Address < ApplicationRecord
  acts_as_paranoid

  geocoded_by :full_address, latitude: :latitude, longitude: :longitude

  after_validation :geocode, if: ->(address) { address.addressable_type == SyClub.name }
  after_update :send_details_to_board_members, :if => Proc.new{ addressable_type == "SyClub" }

  belongs_to :addressable, polymorphic: true
  belongs_to :db_country, class_name: 'DbCountry', foreign_key: 'country_id',
    inverse_of: :addresses, optional: true
  belongs_to :db_state, class_name: 'DbState', foreign_key: 'state_id',
    inverse_of: :addresses, optional: true
  belongs_to :db_city, class_name: 'DbCity', foreign_key: 'city_id',
    inverse_of: :addresses, optional: true

  delegate :name, to: :db_country, prefix: 'country', allow_nil: true
  delegate :currency_code, to: :db_country, prefix: 'country', allow_nil: true
  delegate :telephone_prefix, to: :db_country, prefix: 'country', allow_nil: true
  delegate :ISO2, to: :db_country, prefix: 'country', allow_nil: true

  validate :state_belongs_to_country
  validate :city_belongs_to_state

  scope :forum, ->{ where addressable_type: SyClub.name }

  REQUIRED_FIELD = [:first_line, :state_id, :city_id, :postal_code, :country_id]

  def db_city_id
    city_id
  end

  def db_country_id
    country_id
  end

  def db_state_id
    state_id
  end

  def city_name
    is_in_other_city? ? other_city : db_city&.name
  end

  def state_name
    is_in_other_state? ? other_state : db_state&.name
  end

  def is_in_other_state?
    state_id == OTHER_STATE_ID
  end

  def is_in_other_city?
    city_id == OTHER_CITY_ID
  end

  def street_address
    ("#{first_line} #{second_line}")
  end

  def full_address
    ("#{first_line} #{second_line} #{city_id == 999999 ? other_city : city_name} #{state_id == 99999 ? other_city : state_name} #{country_name} #{postal_code}").split(' ').join(' ')
  end

  private

  def state_belongs_to_country
    return if state_id.blank? || state_id == 99_999
    return if db_state.country_id == country_id.to_i
    errors.add :db_state, 'State does not belong to country'
  end

  def city_belongs_to_state
    return if city_id.blank? || city_id == 999_999
    return if db_city.state_id == state_id.to_i
    errors.add :db_city, 'City does not belong to state'
  end

  def send_details_to_board_members
    sy_club = SyClub.find_by_id(addressable_id)
    UserMailer.forum_creation_notify_board_members(sy_club, false, { is_address_updated: true }).deliver_later if sy_club.present?
  end

end
