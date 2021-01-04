class SadhakProfile < ApplicationRecord
  include PublicActivity::Common
  include AASM

  acts_as_paranoid

  attr_accessor :address_id, :status_notes, :current_user, :event_id
  attr_accessor :temp_id

  extend FriendlyId
  friendly_id :generate_sadhak_profile_slug, use: [:slugged, :finders]

  mount_uploader :avatar, AvatarUploader

  REQUIRED_FIELD_FOR_BASIC_PROFILE = [:first_name, :gender, :date_of_birth]
  REQUIRED_FIELD_FOR_NAME_OF_GURU = [:name_of_guru, :spiritual_org_name]

  # Commented as per discussion
  # SADHAK_PROFILE_SINGLE_ASSOCIATED_MODELS = [:aspects_of_life, :advance_profile, :spiritual_journey, :medical_practitioners_profile, :sadhak_seva_preference]
  SADHAK_PROFILE_SINGLE_ASSOCIATED_MODELS = [:aspects_of_life, :advance_profile, :sadhak_seva_preference]

  attr_accessor :verification_token

  has_paper_trail class_name: 'SadhakProfileVersion', on: [:update, :destroy]

  scope :syid, ->(syid) { where(syid: "sy#{syid.to_s.strip[/-?\d+/].to_i}".upcase) }
  scope :email, ->(email) { where email: email }
  scope :first_name, ->(first_name) { where("LOWER(first_name) = ?", first_name.downcase) }
  scope :last_name, -> (last_name) { where("last_name ILIKE ?", "%#{last_name}%")}
  scope :mobile, ->(mobile) { where mobile: mobile }
  scope :country_id, ->(country_id) { joins(:address).where('addresses.country_id = ?', country_id) }
  scope :state_id, ->(state_id) { joins(:address).where('addresses.state_id = ?', state_id) }
  scope :city_id, ->(city_id) { joins(:address).where('addresses.city_id = ?', city_id) }
  scope :profession_id, ->(profession_id) { joins(:professional_detail).where('professional_details.profession_id = ?', profession_id) }
  scope :occupation, ->(occupation) { joins(:professional_detail).where('professional_details.occupation ILIKE ?', occupation) }
  # To search sadhak_profile using their registration_center
  scope :registration_center_id, ->(registration_center_id){joins(user: :registration_center_users).where(registration_center_users: {registration_center_id: registration_center_id})}

  # Search using date
  scope :from_date, ->(from_date) {where "created_at >= registration_from"}
  scope :end_date, ->(end_date) {where "created_at <= end_date"}

  # Search using registration date
  scope :registration_from, -> (registration_from) {
    joins(:event_registrations)
    .where('DATE(event_registrations.created_at) >= ?', registration_from) }

  scope :registration_to, -> (registration_to) {
    joins(:event_registrations)
    .where('DATE(event_registrations.created_at) <= ?', registration_to) }
  scope :status, lambda { |status| where(status: SadhakProfile.statuses[status]) }

  # Search using creation date
  scope :creation_from, -> (creation_from) { where "DATE(sadhak_profiles.created_at) >= ?", creation_from}
  scope :creation_to, -> (creation_to) { where "DATE(sadhak_profiles.created_at) <= ?", creation_to}
  scope :date_of_birth, ->(date_of_birth) { where("date_of_birth = ?", date_of_birth.to_s) }
  scope :photo_approval_status, ->(status){
    sadhaks_with_s3_url = (joins(advance_profile: [ :advance_profile_photograph]).where("images.s3_url IS NOT NULL").pluck(:id) & joins(advance_profile: [ :advance_profile_identity_proof]).where("images.s3_url IS NOT NULL").pluck(:id)).uniq
    case status.to_i
    when SadhakProfile.ui_photo_approval_statuses["approve"]
      where(
        id: sadhaks_with_s3_url,
        profile_photo_status: SadhakProfile.profile_photo_statuses[:pp_success],
        photo_id_status: SadhakProfile.photo_id_statuses[:pi_success]
      )
    when SadhakProfile.ui_photo_approval_statuses["rejected"]
      where(
        id: sadhaks_with_s3_url,
        profile_photo_status: SadhakProfile.profile_photo_statuses[:pp_rejected],
        photo_id_status: SadhakProfile.photo_id_statuses[:pi_rejected]
      )
    when SadhakProfile.ui_photo_approval_statuses["not_available"]
      where.not(id: sadhaks_with_s3_url)
    when SadhakProfile.ui_photo_approval_statuses["pending"]
      where(
        id: sadhaks_with_s3_url,
        profile_photo_status: SadhakProfile.profile_photo_statuses[:pp_pending],
        photo_id_status: SadhakProfile.photo_id_statuses[:pi_pending]
      )
    end
  }

  scope :non_banned_sadhaks , ->{ where(status: [0, 2, 3, nil]) }

  auto_strip_attributes :first_name, :last_name, :mobile, squish: true
  auto_strip_attributes :email, nullify: false

  validates :first_name, presence: true, length: { maximum: 255, minimum: 2  }
  validates :first_name, format: { with: ONLY_LETTER_AND_SPACE, message: "Only allows letters." }, if: Proc.new{ |sp| first_name_changed? }
  validates :last_name, format: { with: ONLY_LETTER_AND_SPACE, message: "Only allows letters." }, if: Proc.new{ |sp| last_name_changed? && sp.last_name.present? }
  validates :email, format: { with: /\A\S+@.+\.\S+\z/, message: "is not valid."}, allow_blank: true
  validates_date :date_of_birth, before: :today, on_or_after: Date.new(1900, 1, 1), allow_blank: true
  validates :mobile, phone: { allow_blank: true }
  validates :mobile, :email, uniqueness: { allow_blank: true }, on: :create
  validate :mobile_or_email_is_present

  belongs_to :user, optional: true
  has_many :relations, dependent: :destroy
  has_many :users, ->{ where(relations: {is_verified: true}) }, through: :relations, source: :user
  has_one :basic_profile
  has_one :address, as: :addressable

  has_many :other_spiritual_associations, dependent: :destroy
  has_many :shivyog_change_logs, as: :change_loggable, dependent: :destroy
  has_one :professional_detail, dependent: :destroy
  has_one :profession, through: :professional_detail, source: :profession
  has_one :spiritual_practice, dependent: :destroy
  has_one :aspects_of_life, dependent: :destroy
  has_one :shivyog_journey, dependent: :destroy
  has_one :doctors_profile, dependent: :destroy
  has_one :advance_profile, dependent: :destroy
  has_one :spiritual_journey, dependent: :destroy
  has_one :medical_practitioners_profile, dependent: :destroy
  has_one :sadhak_seva_preference, dependent: :destroy
  has_many :event_registrations, dependent: :destroy
  has_many :valid_event_registrations, lambda { where(status: EventRegistration.valid_registration_statuses)}, class_name: 'EventRegistration'
  has_many :events, through: :valid_event_registrations, source: :event
  has_many :valid_event_registrations_without_clp, lambda { where(status: EventRegistration.valid_registration_statuses).where.not(event_id: Event.clp_event_ids)}, class_name: 'EventRegistration'
  has_many :events_without_clp, through: :valid_event_registrations_without_clp, source: :event
  has_many :window_events, lambda { where(%q{events.event_start_date - integer '5' <= CURRENT_DATE AND events.event_end_date + integer '2' >= CURRENT_DATE}).where.not(events: {event_type_id: nil, event_start_date: nil, event_end_date: nil}) }, through: :valid_event_registrations_without_clp, source: :event

  # has_many :renewal_registrations
  has_many :renewal_events#, :through => :renewal_registrations, source: :event

  has_many :event_references, dependent: :destroy
  has_many :event_sponsors, dependent: :destroy
  has_many :sy_club_sadhak_profile_associations, dependent: :destroy
  has_many :sy_clubs, through: :sy_club_sadhak_profile_associations
  has_many :sy_club_references, dependent: :destroy
  has_many :reference_clubs, through: :sy_club_references, source: :sy_club
  has_many :sy_club_members, dependent: :destroy
  has_many :joined_clubs, through: :sy_club_members, source: :sy_club
  has_many :special_event_sadhak_profile_other_infos, dependent: :destroy
  # has_many :active_clubs, lambda { where(sy_club_members: {status: SyClubMember.statuses[:approve]}).where.not(sy_club_members: {event_registration_id: nil}) }, through: :sy_club_members, source: :sy_club
  has_many :forum_memberships, lambda { where(sy_club_members: {status: SyClubMember.statuses[:approve]}).where.not(sy_club_members: {event_registration_id: nil}) }, foreign_key: 'sadhak_profile_id', class_name: 'SyClubMember'
  # has_many :event_registrations
  # has_many :club_events, :through => :event_registrations
  # has_many :registration_centers, :through => :users, source: :registration_centers
  has_one :advisory_counsil
  accepts_nested_attributes_for :spiritual_practice, :professional_detail, :medical_practitioners_profile, :sadhak_seva_preference, :spiritual_journey, :special_event_sadhak_profile_other_infos
  # accepts_nested_attributes_for :other_spiritual_associations, :allow_destroy => true
  accepts_nested_attributes_for :address, :allow_destroy => true
  accepts_nested_attributes_for :advance_profile, :allow_destroy => true
  accepts_nested_attributes_for :doctors_profile, reject_if: :is_not_doctor_profession?
  # accepts_nested_attributes_for :shivyog_journey, :allow_destroy => true
  has_many :sadhak_profile_attended_shivirs, dependent: :destroy
  has_one :extension_detail

  #accepts_nested_attributes_for :sadhak_profile_attended_shivirs

  before_validation :format_phone
  after_create :assign_syid
  after_save :check_profession, if: :is_not_doctor_profession?
  before_save :sadhak_profile_before_save
  before_save :track_status_changes
  before_save :update_profile_photo_and_photo_id_status, if: Proc.new{ |sp| (first_name_changed? || last_name_changed?) && sp.profile_photo_status == 'pp_success' && sp.photo_id_status == 'pi_success' }
  after_create :user_create
  before_save :validate_under_age, if: :date_of_birth_changed?
  after_update :update_user_contact_info, if: proc{ |sp| sp.email_changed? || sp.mobile_changed?}

  delegate :name, to: :profession, prefix: "profession", allow_nil: true
  delegate :full_address, to: :address, allow_nil: true
  delegate :street_address, to: :address, allow_nil: true
  delegate :country_name, to: :address, allow_nil: true
  delegate :state_name, to: :address, allow_nil: true
  delegate :city_name, to: :address, allow_nil: true
  delegate :country_currency_code, to: :address, allow_nil: true
  delegate :country_telephone_prefix, to: :address, allow_nil: true
  delegate :country_ISO2, to: :address, allow_nil: true
  delegate :postal_code, to: :address, allow_nil: true
  delegate :advance_profile_s3_url, to: :advance_profile, allow_nil: true
  delegate :advance_profile_identity_proof_s3_url, to: :advance_profile, allow_nil: true
  delegate :advance_profile_address_proof_s3_url, to: :advance_profile, allow_nil: true
  delegate :advance_profile_thumb_url, to: :advance_profile, allow_nil: true
  delegate :advance_profile_identity_proof_thumb_url, to: :advance_profile, allow_nil: true
  delegate :advance_profile_address_proof_thumb_url, to: :advance_profile, allow_nil: true
  delegate :photo_id_proof_type_name, to: :advance_profile, allow_nil: true
  delegate :address_proof_type_name, to: :advance_profile, allow_nil: true
  delegate :photo_id_proof_number, to: :advance_profile, allow_nil: true

  def check_profession
    self.doctors_profile.try(:destroy)
  end

  def is_not_doctor_profession?
    professional_detail.try(:profession).try(:name) != DOCTOR
  end

  def active?
    status == 'active'
  end

  def active_club_ids
    self.forum_memberships.select do |m|
      SyClubMember.statuses[m.status] == SyClubMember.statuses['approve']
    end.collect(&:sy_club_id)
  end

  def active_club
    forum_memberships.first.try(:sy_club)
  end

  def active_forum_name
    forum_memberships.first.try(:forum_name)
  end

  def expiration_date
    forum_memberships.first.try(:expiration_date)
  end

  def board_member_position
    role = sy_club_sadhak_profile_associations.first.try(:sy_club_user_role)
    sy_club = sy_clubs.first
    return unless sy_club.present?
    (sy_club.sadhak_profiles.count == 2 && sy_club.sy_club_sadhak_profile_associations.pluck(:sy_club_user_role_id).include?(1)) ? role.try(:role_name).tr("0-9", "").try(:titleize) : role.try(:role_name).try(:titleize)
  end

  def board_member_forum_name
    sy_clubs.first.try(:name)
  end

  enum profile_photo_status: { pp_pending: 0, pp_success: 1, pp_rejected: 2 }
  aasm :aasm_profile_photo_status, column: :profile_photo_status, enum: true, whiny_transitions: false do
    state :pp_pending, initial: true
    state :pp_success
    state :pp_rejected

    event :pp_approve do
      transitions to: :pp_success, guard: :guard_profile_photo_and_photo_id_status_change?
    end

    event :pp_reject do
      transitions to: :pp_rejected, guard: :guard_profile_photo_and_photo_id_status_change?
    end
  end

  enum photo_id_status: { pi_pending: 0, pi_success: 1, pi_rejected: 2 }
  aasm :aasm_photo_id_status, column: :photo_id_status, enum: true, whiny_transitions: false do
    state :pi_pending, initial: true
    state :pi_success
    state :pi_rejected

    event :pi_approve do
      transitions to: :pi_success, guard: :guard_profile_photo_and_photo_id_status_change?
    end

    event :pi_reject do
      transitions to: :pi_rejected, guard: :guard_profile_photo_and_photo_id_status_change?
    end
  end

  def guard_profile_photo_and_photo_id_status_change?
    @sp = @sp || SadhakProfile.find(self.id)

    if self.advance_profile.present? && self.advance_profile.advance_profile_photograph.present? && self.advance_profile.advance_profile_identity_proof.present?
      change_log = self.shivyog_change_logs.last
      creator_sadhak_profile = change_log.try(:creator).try(:sadhak_profile)

      if @sp.pp_success? && @sp.pi_success?
        self.errors.add("#{self.syid}", "-#{self.full_name} profile is already approved by #{creator_sadhak_profile.try(:full_name)}. Please refresh the page.")
      elsif @sp.pp_rejected? && @sp.pi_rejected?
        self.errors.add("#{self.syid}", "-#{self.full_name} profile is already rejected by #{creator_sadhak_profile.try(:full_name)}. Please refresh the page.")
      end
    else
      self.errors.add("#{self.syid}", "-#{self.full_name} profile photo and photo id are not available.")
    end

    errors.empty?
  end

  enum address_proof_status: { ap_pending: 0, ap_success: 1, ap_rejected: 2 }
  aasm :aasm_address_proof_status, column: :address_proof_status, enum: true, whiny_transitions: false do
    state :ap_pending, initial: true
    state :ap_success
    state :ap_rejected

    event :ap_approve do
      transitions from: :ap_pending, to: :ap_success
    end

    event :ap_reject do
      transitions from: :ap_pending, to: :ap_rejected
    end
  end

  enum status: { temporary_blocked: 0, banned: 1, pending_approval: 2, approved: 3 }

  enum ui_photo_approval_status: [ :approve, :rejected, :pending, :not_available ]

  def user_create
    return if self.user_id.present?
    if date_of_birth.present? && date_of_birth <= Date.current
      is_under_age = age < SADHAK_MIN_AGE
      user_params = {
        name: first_name,
        last_name: last_name,
        password: Devise.friendly_token.first(8),
        date_of_birth: date_of_birth,
        gender: gender,
        email: email,
        contact_number: mobile,
        sadhak_profile_id: id
      }
      self.create_user!(user_params)
      user_id = self.user.id
      self.update_attributes(user_id: user_id, is_under_age: is_under_age)
    end
  end

  def assign_syid
    self.update_column(:syid, "SY#{self.id}")
  end

  def sadhak_profile_before_save
    # need to verify this
    self.address = Address.find(address_id) if self.address_id.present?
    self.is_mobile_verified = 0 if self.mobile_changed?
    self.is_email_verified = 0 if self.email_changed?

    # Mark profile photo and photo id status as pending if first name or last name updated
    if (first_name_changed? || last_name_changed?) && self.advance_profile.present? && self.advance_profile.advance_profile_photograph.present? && self.advance_profile.advance_profile_identity_proof.present?
        self.profile_photo_status = 'pp_pending'
        self.photo_id_status = 'pi_pending'
    end
    errors.empty?
  end

  def track_status_changes
    event = Event.find_by_id(self.event_id)

    from = GetSenderEmail.call(event || self)

    # if sadhak profile status changed, Create a status change log entery
    if self.status_changed?
      # attribute_name, value_before, value_after, description, change_loggable_id, change_loggable_type
      change_log = self.create_change_log('status', self.status_was, self.status, self.status_notes)

      errors.messages.merge!(change_log.errors.messages) && errors.details.merge!(change_log.errors.details) && throw(:abort) unless change_log.errors.empty?
    end

    if self.profile_photo_status_changed? && (self.pp_rejected? || self.pp_success?)

      if self.pp_success?
        self.status_notes = 'Approved'
      end

      change_log = self.create_change_log('profile_photo_status', self.profile_photo_status_was, self.profile_photo_status, self.status_notes)

      errors.messages.merge!(change_log.errors.messages) && errors.details.merge!(change_log.errors.details) && throw(:abort) unless change_log.errors.empty?
    end

    if self.photo_id_status_changed? && (self.pi_rejected? || self.pi_success?)

      if self.pi_success?
        self.status_notes = 'Approved'
      end

      change_log = self.create_change_log('photo_id_status', self.photo_id_status_was, self.photo_id_status, self.status_notes)

      errors.messages.merge!(change_log.errors.messages) && errors.details.merge!(change_log.errors.details) && throw(:abort) unless change_log.errors.empty?
    end

    # Send notification SMS and email about rejection of photo and photo id
    if (errors.empty? && (self.profile_photo_status_changed? && self.pp_rejected?) || (self.photo_id_status_changed? && self.pi_rejected?))

      # if photo id status changed, create a status change log entery
      # Considering only when photo id is rejected

      default_text = 'Your Photo or Photo ID is rejected. Please make sure to upload correct and clear photo and photo ID. Please make sure that picture of your face is clearly visible in your photo.'
      default_email_subject = 'Photo and Photo ID Rejected.'
      email_text = GlobalPreference.get_value_of('photo_and_photo_id_rejection_email_text')
      sms_text = GlobalPreference.get_value_of('photo_and_photo_id_rejection_sms_text')
      email_subject = GlobalPreference.get_value_of('photo_and_photo_id_rejection_email_subject')
      email_text ||= default_text
      sms_text ||= default_text
      email_subject ||= default_email_subject

      # Notify by Email
      ApplicationMailer.send_email(from: from, recipients: self.email, subject: email_subject, template: 'sadhak_profile_photo_and_photo_id_proof_rejection_notification', sadhak_profile: self, email_text: email_text).deliver_later if self.email.to_s.is_valid_email?

      # Notify by SMS
      self.delay.send_sms_to_sadhak("NMS #{self.syid}-#{self.full_name}\n#{sms_text}")
    end

    # if address proof status changed, create a status change log entery
    # Considering only when address proof is rejected
    if self.address_proof_status_changed? && (self.ap_rejected? || self.ap_success?)

      if self.ap_success?
        self.status_notes = 'Approved'
      end

      change_log = self.create_change_log('address_proof_status', self.address_proof_status_was, self.address_proof_status, self.status_notes)

      errors.messages.merge!(change_log.errors.messages) && errors.details.merge!(change_log.errors.details) && throw(:abort) unless change_log.errors.empty?
    end

    # Send email and SMS notifying sadhak about their Profile photo and Photo Id proof approved.
    if (self.profile_photo_status_changed? || self.photo_id_status_changed?) && self.pp_success? && self.pi_success? && self.advance_profile.present? && self.advance_profile.advance_profile_photograph.present? && self.advance_profile.advance_profile_identity_proof.present? && errors.empty?

      default_text = 'We wish to inform you that your photo and photo ID has been approved.'

      default_email_subject = 'Photo and Photo ID Approved.'

      email_text = GlobalPreference.get_value_of('photo_and_photo_id_approval_email_text')

      sms_text = GlobalPreference.get_value_of('photo_and_photo_id_approval_sms_text')

      email_subject = GlobalPreference.get_value_of('photo_and_photo_id_approval_email_subject')

      email_text ||= default_text

      sms_text ||= default_text

      email_subject ||= default_email_subject

      # Notify by Email
      ApplicationMailer.send_email(from: from, recipients: self.email, subject: email_subject, template: 'sadhak_profile_photo_and_photo_id_proof_approval_notification', sadhak_profile: self, email_text: email_text).deliver_later if self.email.to_s.is_valid_email?

      # Notify by SMS
      self.delay.send_sms_to_sadhak("NMS #{self.syid}-#{self.full_name}\n#{sms_text}")

      # Disable for now : As per request on email Fwd: to remove entry cards details
      # self.delay.dispatch_entry_cards

    end

    errors.empty?
  end

  def dispatch_entry_cards
    event_ids = GlobalPreference.where(key: %w(india_clp_events global_clp_events)).collect{|gp| gp.try(:val).to_s.split(',')}.flatten

    notification_text = 'Please find attached entry card with this email. Please take a coloured print of your entry card and bring along with your photo ID proof in shivir.'

    self.event_registrations.joins(:event).where('event_registrations.status IN (?) AND events.event_start_date >= ? AND events.id NOT IN (?) AND events.shivir_card_enabled = ?', EventRegistration.valid_registration_statuses, (Date.today - 1.day), event_ids, true).includes(:event, :event_order).order('events.event_end_date').each do |event_registration|

      attachments = {}
      event = event_registration.event
      from = GetSenderEmail.call(event || self)

      begin
        card = self.generate_shivir_card(event_registration.try(:reg_ref_number))

        attachments["#{self.syid.downcase}_registration_card_event_#{event.id}_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.pdf"] = card

        ApplicationMailer.send_email(from: from, recipients: self.email, subject: "Entry Card - #{event.event_name}", template: 'sadhak_profile_entry_card_notification_after_photo_and_photo_id_approved', sadhak_profile: self, email_text: notification_text, attachments: attachments).deliver_now if self.email.to_s.is_valid_email?

      rescue Exception => e
      end
    end
  end

  # Callback run when user try to update first name and last name and photo and photo id status were approved
  def update_profile_photo_and_photo_id_status
    self.profile_photo_status = SadhakProfile.profile_photo_statuses.pp_pending
    self.photo_id_status = SadhakProfile.photo_id_statuses.pi_pending
  end

  def check_profile_completeness
    UpdateSadhakProfileCompleteness.call(self)
  end

  def add_to_user(user)
    if !user.sadhak_profiles.include?(self)
      verification_code = SecureRandom.random_number(1000000)
      Relation.create(
        user_id: user.id,
        sadhak_profile: self,
        syid: self.syid,
        relationship_type: 'group_member',
        is_verified: false,
        verification_code: verification_code
      )
    else
      Relation.find_by(sadhak_profile_id: self.id, user_id: user.id)
    end
  end

  def full_name
    [first_name, middle_name, last_name].select(&:present?).map(&:capitalize).join(' ')
  end

  def validates_username
    is_taken = self.class.where(username: self.username).count == 0
    errors.add(:username, "has already been taken.") unless is_taken
    errors.as_json.blank?
  end

  def verify_by_rc(user, rc_event_id)
    is_rc_user = false
    registration_center_users = RegistrationCenterUser.includes(:registration_center).where(registration_center_id: EventRegistrationCenterAssociation.where(event_id: rc_event_id).pluck(:registration_center_id))
    registration_center_users.each do |rcu|
      is_rc_user = (rcu.user_id == user.try(:id) and rcu.registration_center.present? and rcu.registration_center.start_date.to_date <= Date.current and rcu.registration_center.end_date.to_date >= Date.current)
      break if is_rc_user
    end
    is_rc_user
  end

  def send_sms_to_sadhak(message = 'This is default SMS from SHIVYOG.')
    begin
      success = true
      res = nil
      error = nil

      # Log the SMS
      Rails.logger.info("SadhakProfile: send_sms_to_sadhak - Message for SYID: #{self.try(:syid)} is :\n#{message}\nMessage length : #{message.length}.")
      if (self.try(:user).try(:unconfirmed_mobile).present? || self.mobile.present?)

        # Collect information that is needed to send a SMS
        telephone_prefix = address.try :country_telephone_prefix
        country_code = address.try :country_ISO2

        mobile = self.try(:user).try(:unconfirmed_mobile) || self.mobile

        # Logic to reduce message size if > max_message_length characters
        part = 0

        max_message_length = 3000

        begin
          parted_msg = message[(part * max_message_length)..(((part + 1) * max_message_length) - 1)]

          res, error = SendSms.call(mobile, telephone_prefix, parted_msg, country_code.to_s)

          # Check for errors
          if error.present?
            success = false
            break
          end

          part += 1

        end while part <= (message.length / max_message_length)

        success = false if error.present?

      else
        Rails.logger.info("SadhakProfile: send_sms_to_sadhak SYID: #{self.try(:syid)} - Either mobile or address is not present.")
        Rails.logger.info("SadhakProfile: send_sms_to_sadhak SYID: #{self.try(:syid)} - Mobile: #{mobile}, Address: #{self.try(:address).try(:inspect)}.")
        success = false
      end
    rescue Exception => e
      Rails.logger.info("SadhakProfile: send_sms_to_sadhak - SYID: #{self.try(:syid)} Runtime Exception: #{e.message}")
      success = false
    end
    success
  end

  def renewal_events
    EventRegistration.where(
      sadhak_profile_id: self.id,
      status: EventRegistration.valid_registration_statuses
    ).select do |e|
      val = (e.created_at.to_date + e.expires_at.to_i) - Date.today
      val <= 30 && val > 0
    end.collect(&:event)
  end

  def self.all_non_member_sadhaks
    joins(:sy_club_members, :address).where.not(sy_club_members: {status: SyClubMember.statuses[:approve]}).where(sy_club_members: {event_registration_id: nil})
  end

  def self.preloaded_data
    SadhakProfile.includes(SadhakProfile.includable_data)
  end

  def self.includable_data
    [
      { address: [:db_city, :db_state, :db_country] },
      { professional_detail: [:profession] },
      { advance_profile: [:advance_profile_photograph, :advance_profile_identity_proof, :advance_profile_address_proof] },
      { medical_practitioners_profile: [:medical_practitioner_speciality_area] },
      { aspects_of_life: [:aspect_feedbacks] },
      :events, :user, :doctors_profile, :other_spiritual_associations,
      { sy_club_sadhak_profile_associations: [:sy_club_user_role] }, :sy_clubs, :sadhak_seva_preference, :users, :relations,
      { forum_memberships: [:sy_club, {event_registration: [:event_order]}] }
    ]
  end

  def age
    today = Date.current
    offset = today.yday >= date_of_birth.yday ? 0 : 1
    today.year - date_of_birth.year - offset
  rescue => e
    Rollbar.error(e)
    0
  end

  def notify_sadhak(options = {})
    return false if options.blank?
    medium = nil
    medium_value = nil
    if self.is_email_verified? and self.email.present?
      medium = 'email'
      medium_value = self.email
    elsif self.is_mobile_verified? and self.mobile.present?
      medium = 'mobile'
      medium_value = self.mobile
    elsif self.email.present?
      medium = 'email'
      medium_value = self.email
    elsif self.mobile.present?
      medium = 'mobile'
      medium_value = self.mobile
    elsif self.user.present?
      if self.user.email.present?
        medium = 'email'
        medium_value = self.user.email
      elsif self.user.contact_number.present?
        medium = 'mobile'
        medium_value = self.user.contact_number
      end
    end
    if medium == 'email'
      email_async(options.merge({recipients: medium_value, sadhak_profile: self}))
    elsif medium == 'mobile'
      self.send_sms_to_sadhak(options[:message])
    end
  end

  def check_prerequisite_criterion?(event)
    result = event.present?
    if result
      prerequisite_event_ids = event.prerequisite_events.ids + Event.where(event_type_id: event.event_prerequisites_event_types.pluck(:event_type_id)).pluck(:id)
      attended_event_ids = self.events.select{|e| e.event_end_date.present? && e.event_end_date < Date.today || e.end_date_ignored?}.collect{|e| e.id}
      if prerequisite_event_ids.present?
        result = (prerequisite_event_ids & attended_event_ids).size > 0
      end
    end
    result
  end

  def generate_shivir_card(reg_ref_number)
    event_order = EventOrder.find_by_reg_ref_number(reg_ref_number)

    raise 'Event order not found.' unless event_order.present?

    event = event_order.event

    raise 'Shivir card download is not enabled for this event.' unless event.shivir_card_enabled?

    raise "#{self.syid}-#{self.full_name} your application is under process. Contact ashram for more details." unless self.events.include?(event)

    raise "#{self.syid}-#{self.full_name} no details found. Contact ashram for more details." unless event_order.registered_sadhak_profiles.include?(self)

    raise 'Either event is closed or ongoing. Unable to generate entry card. Contact ashram for more details' unless event.event_start_date.present? && event.event_start_date >= (Date.today - 1.day)

    raise "#{self.syid}-#{self.full_name} your application is under process. Contact ashram for more details." unless event_order.success? || (event_order.payment_method == 'Demand draft' && (event_order.dd_received_by_ashram? || event_order.dd_received_by_india_admin? || event_order.dd_received_by_rc?))

    event_ids = GlobalPreference.where(key: %w(india_clp_events global_clp_events)).collect{|gp| gp.try(:val).to_s.split(',')}.flatten.map(&:to_i)

    raise "Unable to generate entry card for event #{event.event_name}. Contact ashram for more details" if event_ids.include?(event.id)

    raise "#{self.syid}-#{self.full_name} advance profile is not yet completed. Please complete it first." unless self.advance_profile.present?

    raise "#{self.syid}-#{self.full_name} profile photo is not uploaded. Please upload it first." unless self.advance_profile.advance_profile_photograph.present?

    raise "#{self.syid}-#{self.full_name} photo id proof is not uploaded. Please upload it first." unless self.advance_profile.advance_profile_identity_proof.present?

    raise "#{self.syid}-#{self.full_name} profile photo is under approval. Once it approved you will be notified. Please make sure that you have uploaded your correct profile photo." unless self.profile_photo_status == 'pp_success'

    raise "#{self.syid}-#{self.full_name} photo id proof is under approval. Once it approved you will be notified. Please make sure that you have uploaded your correct photo id proof." unless self.photo_id_status == 'pi_success'

    event_registration = self.event_registrations.where(status: EventRegistration.valid_registration_statuses, event_id: event.id).last

    raise "#{self.syid}-#{self.full_name} registration not found. Contact ashram for more details." unless event_registration.present?

    profile_photo_url = self.advance_profile.advance_profile_photograph.s3_url || if self.gender.present? then
                          if self.gender.downcase == 'male' then
                            'https://s3.amazonaws.com/syregportalprofilepictures/no_image_male.jpg'
                          else
                            self.gender.downcase == 'female' ? 'https://s3.amazonaws.com/syregportalprofilepictures/no_image_female.jpg' : 'https://s3.amazonaws.com/syregportalprofilepictures/no_image_other.jpg'
                          end
                        else
                          'https://s3.amazonaws.com/syregportalprofilepictures/no_image_other.jpg'
                        end

    stdt = event.try(:event_start_date)
    eddt = event.try(:event_end_date)

    event_dates = if (eddt.present? and stdt.present?) then
      if (stdt.year == eddt.year and stdt.month == eddt.month and stdt.day == eddt.day) then
        "#{stdt.day}<sup>#{ActiveSupport::Inflector.ordinal(stdt.day)}</sup> #{stdt.strftime('%b')} #{stdt.strftime('%Y')}"
      else
        if (stdt.year == eddt.year and stdt.month == eddt.month) then
          "#{stdt.day}<sup>#{ActiveSupport::Inflector.ordinal(stdt.day)}</sup> to #{eddt.day}<sup>#{ActiveSupport::Inflector.ordinal(eddt.day)}</sup> #{stdt.strftime('%b')} #{stdt.strftime('%Y')}"
        else
          (stdt.year == eddt.year) ? "#{stdt.day}<sup>#{ActiveSupport::Inflector.ordinal(stdt.day)}</sup> #{stdt.strftime('%b')} to #{eddt.day}<sup>#{ActiveSupport::Inflector.ordinal(eddt.day)}</sup> #{eddt.strftime('%b')} #{stdt.strftime('%Y')}" : "#{stdt.day}<sup>#{ActiveSupport::Inflector.ordinal(stdt.day)}</sup> #{stdt.strftime('%b')} #{stdt.strftime('%Y')} to #{eddt.day}<sup>#{ActiveSupport::Inflector.ordinal(eddt.day)}</sup> #{eddt.strftime('%b')} #{eddt.strftime('%Y')}"
        end
      end
    else
      'NA'
    end

    file = open(profile_photo_url)

    begin
      file = File.open(validate_file_type(file, profile_photo_url), 'r')
      profile_photo_url = File.basename(profile_photo_url, '.*') + '.png'
    rescue Exception
    end

    profile_photo = Base64.strict_encode64(file.read)

    profile_photo_url =  File.basename(self.advance_profile.advance_profile_photograph.try(:name).try(:file).try(:filename), '.*') + '.png' || profile_photo_url

    profile_photo = "data:#{MIME::Types.type_for(profile_photo_url).first.content_type};base64,#{profile_photo}"

    File.delete(file) if File.exist?(file)

    max_char_length = 40
    event_name = ''
    i = 1
    remain_event_name = event.event_name

    if remain_event_name.length > max_char_length
      loop do
        last_space_index = remain_event_name[0...max_char_length].rindex(' ')

        unless last_space_index.present?
          event_name += remain_event_name
          break
        end

        event_name += remain_event_name[0..last_space_index]
        remain_event_name = remain_event_name[(last_space_index+1)..remain_event_name.length]
        break if remain_event_name.length <= 0 || i >= 2
        event_name += '<br>'
        i += 1
      end
    else
      event_name = remain_event_name
    end

    data = {
        syid: self.syid,
        full_name: self.try(:full_name),
        seating_category: event_registration.try(:seating_category).try(:category_name),
        registration_number: event.sy_event_company_id.present? ? event_registration.serial_number + 100 : event_registration.event_order_line_item.registration_number,
        profile_photo: profile_photo,
        event_name: event_name,
        event_location: event.try(:event_location),
        event_dates: event_dates
    }

    self.generate_pdf(:pdf, data, 'invoices/event_card.html.erb')
  end

  def photo_and_photo_id_approved?
    self.advance_profile.present? && self.advance_profile.advance_profile_photograph.present? && self.advance_profile.advance_profile_identity_proof.present? && self.profile_photo_status == 'pp_success' && self.photo_id_status == 'pi_success'
  end

  def salutation
    'Mr. / Ms. / Mrs.'
  end

  # Completeness of Name Of Guru section
  def name_of_guru_completeness
    cal_completeness(SadhakProfile::REQUIRED_FIELD_FOR_NAME_OF_GURU)
  end

  def is_name_of_guru_complete?
    name_of_guru_completeness.to_i == 100
  end

  # Completeness of Basic Profile section
  def basic_profile_completeness
    cal_completeness(SadhakProfile::REQUIRED_FIELD_FOR_BASIC_PROFILE)
  end

  def basic_profile_address_completeness
    address.cal_completeness(Address::REQUIRED_FIELD)
  end

  def is_basic_profile_complete?
    basic_profile_completeness.to_i == 100 && is_verified?
  end

  def is_basic_profile_address_complete?
    address && basic_profile_address_completeness == 100
  end

  def professional_detail_completeness
    NON_PROFESSIONAL_PROFESSIONS.include?(professional_detail.try(:profession).try(:name)) ? professional_detail.cal_completeness(ProfessionalDetail::NON_PROFESSIONAL_REQUIRED_FIELD) : professional_detail.cal_completeness(ProfessionalDetail::REQUIRED_FIELD)
  end

  def is_professional_detail_complete?
    professional_detail && professional_detail_completeness.to_i == 100
  end

  def is_doctors_profile_completed?
    doctors_profile && doctors_profile.cal_completeness(DoctorsProfile::REQUIRED_FIELD).to_i == 100
  end

  def completed
    completed_percent = 0.00

    SADHAK_PROFILE_SINGLE_ASSOCIATED_MODELS << "medical_practitioners_profile".to_sym unless is_not_doctor_profession?

    per_asso_weightage = 100.00/(SADHAK_PROFILE_SINGLE_ASSOCIATED_MODELS.size + 5)

    SADHAK_PROFILE_SINGLE_ASSOCIATED_MODELS.each do |asso|
      completed_percent += self.send(asso).try(:cal_completeness).to_f * per_asso_weightage * 0.01
    end

    completed_percent += 100.to_f * per_asso_weightage * 0.01 if sadhak_profile_attended_shivirs.present?
    completed_percent += 100.to_f * per_asso_weightage * 0.01 if is_basic_profile_complete?
    completed_percent += 100.to_f * per_asso_weightage * 0.01 if is_basic_profile_address_complete?
    completed_percent += 100.to_f * per_asso_weightage * 0.01 if is_name_of_guru_complete?
    completed_percent += 100.to_f * per_asso_weightage * 0.01 if is_professional_detail_complete?
    completed_percent
  end

  def completed?
    completed.to_i == 100
  end

  def email_verification_needed?
    email.present? && !is_email_verified?
  end

  def mobile_verification_needed?
    mobile.present? && !is_mobile_verified?
  end

  def send_email_verification
    raise ArgumentError unless email_verification_needed?

    self.update_attribute :email_verification_token, SecureRandom.random_number(1000000)

    ApplicationMailer.send_email(
      full_name: full_name,
      verification_token: email_verification_token,
      recipients: email,
      subject: "Verify Your Sadhak Profile ID Email Address",
      template: 'user_mailer/sadhak_email_confirmation_notice'
    ).deliver_now
  end

  def send_mobile_verification
    raise ArgumentError unless mobile_verification_needed?

    self.update_attribute :mobile_verification_token, SecureRandom.random_number(1000000)
    message_body = "Namah Shivay #{full_name} Ji,\nYour mobile verification token is #{mobile_verification_token}"
    send_sms_to_sadhak(message_body)
  end

  def send_verification_token

      ApplicationRecord.transaction do

        email_ad = self.try(:user).try(:unconfirmed_email) || self.email
        mobile_number = self.try(:user).try(:unconfirmed_mobile) || self.mobile

        self.email_verification_token = self.mobile_verification_token = nil

        self.mobile_verification_token = SecureRandom.random_number(1000000) if mobile_number.present?
        self.email_verification_token = SecureRandom.random_number(1000000) if email_ad.present?

        message_body = "Namah Shivay #{full_name} Ji,\nYour mobile verification token is " + mobile_verification_token.to_s

        # Send verification token to sadhak profile's email id
        email_res = ApplicationMailer.send_email(full_name: full_name, verification_token: email_verification_token, recipients: email_ad, subject: "Verify Your Sadhak Profile ID Email Address", template: 'user_mailer/sadhak_email_confirmation_notice').deliver_now if email_ad.present?

        # Send verification token to sadhak profile's mobile number
        if mobile_number.present?
          mobile_res = send_sms_to_sadhak(message_body)
          raise SyException, "Invalid mobile number." unless mobile_res.present?
        end

        send_verification_token_to_admin if $current_user && $current_user.try(:sadhak_profile) && $current_user.try(:sadhak_profile) != self && $current_user.try(:sadhak_profile).try(:email).present? && ($current_user.super_admin? || $current_user.india_admin?)
    end

    self
  end

  def send_verification_token_to_admin
    email_res = ApplicationMailer.send_email(verification_token: (email_verification_token || mobile_verification_token), recipients: $current_user.sadhak_profile.email, subject: "Sadhak Profile Verification Token", template: 'user_mailer/sadhak_confirmation_by_admin.html.erb').deliver_now
  end

  def generate_sadhak_profile_slug
    "#{SecureRandom.uuid}-#{SecureRandom.hex(3)}"
  end

  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end

  def update_user_contact_info
    user.update_attributes(email: email, contact_number: mobile)
  end

  def create_public_activity(data = {})
    create_activity "update_sadhak_profile_by_admin", owner: $current_user.sadhak_profile, params: data
  rescue StandardError => e
    Rollbar.error(e)
  end

  def is_verified?
    (mobile.present? && is_mobile_verified?) || (email.present? && is_email_verified?)
  end

  def update_or_verify(update_sadhak_profile_params)
    sadhak_profile_params, sadhak_profile_verification_needed, @unconfirmed_mobile, @unconfirmed_email = update_sadhak_profile_params, false, nil, nil
    if update_sadhak_profile_params.has_key?(:email) || update_sadhak_profile_params.has_key?(:mobile)

      if update_sadhak_profile_params[:mobile] != mobile && update_sadhak_profile_params[:email] != email

        # if @sadhak_profile.is_email_verified? && @sadhak_profile.is_mobile_verified?
        @unconfirmed_email, @unconfirmed_mobile, medium, sadhak_profile_verification_needed, sadhak_profile_params = update_sadhak_profile_params[:email], update_sadhak_profile_params[:mobile], MEDIUM_TO_SEND_VERIFICATION_TOKEN[2], true, update_sadhak_profile_params.except(:email, :mobile)

        if update_sadhak_profile_params[:mobile].present? && update_sadhak_profile_params[:email].present?
          medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[2]
        elsif update_sadhak_profile_params[:mobile].present?
          medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]
        elsif update_sadhak_profile_params[:email].present?
          medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]
        else
          raise SyException, "Email or mobile can't be blank."
        end

      elsif update_sadhak_profile_params[:mobile] != mobile && !self.is_email_verified?

         medium = email.present? ? MEDIUM_TO_SEND_VERIFICATION_TOKEN[2] : MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]

        # When updated mobile is blank then token will be send to your email only so that sadhak profile can be verified.
        if !update_sadhak_profile_params[:mobile].present? && email.present?
          medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]
          @unconfirmed_email = email
        end
        @unconfirmed_mobile,sadhak_profile_verification_needed, sadhak_profile_params = update_sadhak_profile_params[:mobile], true, update_sadhak_profile_params.except(:mobile)

      elsif update_sadhak_profile_params[:email] != email && !is_mobile_verified?

        medium = mobile.present? ? MEDIUM_TO_SEND_VERIFICATION_TOKEN[2] : MEDIUM_TO_SEND_VERIFICATION_TOKEN[0]

        # When updated email is blank then token will be send to your mobile only so that sadhak profile can be verified.
        if !update_sadhak_profile_params[:email].present? && mobile.present?
          medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]
          @unconfirmed_mobile = mobile
        end
        @unconfirmed_email, sadhak_profile_verification_needed, sadhak_profile_params = update_sadhak_profile_params[:email], true, update_sadhak_profile_params.except(:email)

      elsif !is_verified?
        @unconfirmed_mobile,sadhak_profile_verification_needed, sadhak_profile_params, medium = update_sadhak_profile_params[:mobile], true, update_sadhak_profile_params.except(:mobile), MEDIUM_TO_SEND_VERIFICATION_TOKEN[1]  if mobile.present?
        @unconfirmed_email, sadhak_profile_verification_needed, sadhak_profile_params, medium = update_sadhak_profile_params[:email], true, update_sadhak_profile_params.except(:email), MEDIUM_TO_SEND_VERIFICATION_TOKEN[0] if email.present?
        medium = MEDIUM_TO_SEND_VERIFICATION_TOKEN[2] if email.present? && mobile.present?

      end

    else
      # Do nothing
    end
    # Update sadhak profile's field except email and mobile.
    raise SyException, self.errors.full_messages.first unless self.update(sadhak_profile_params)

    # Check whether token verification is needed to update sadhak profile.
    if sadhak_profile_verification_needed
      ActiveRecord::Base.transaction do

        # Set email as unconfirmed mail until mail is not verified.
        # Set mobile as unconfirmed mobile until mobile is not verified.
        user.update_attributes(unconfirmed_email: @unconfirmed_email, unconfirmed_mobile: @unconfirmed_mobile)

        # Set verification token and return sadhak profile.
        # Save sadhak profile's verification tokens.
        send_verification_token.save
      end
    end
    return medium, sadhak_profile_verification_needed
  end

  def full_name_with_syid
    "#{full_name} / #{syid}".split("/").map(&:strip).join(" / ")
  end

  def verify_registration_for_event(event = nil)
    raise "Event not found." unless event.present?

    # Check for sadhak profile already registered
    raise "#{syid}-#{full_name} is already registered to this event." if events.include?(event)

    # Check for banned profile
    raise SyException, "#{syid}-#{full_name} is not allowed to register on event." if banned?

    # Check for prerequistic
    unless check_prerequisite_criterion?(event)
      prerequisite_events_string = (event.prerequisite_events + Event.where(event_type_id: event.event_prerequisites_event_types.pluck(:event_type_id))).collect{|e| e.event_name_with_location}.join(' | ')
      alert_message = event.prerequisite_message.present? ? event.prerequisite_message : "In order to register for #{event.event_name}, it is mandatory that you have attended #{prerequisite_events_string}."
      raise "#{syid}-#{full_name} does not meet prerequisite criterion. #{alert_message}"
    end

    # Check for Pre-approval Events
    if event.pre_approval_required?
      line_item = event.event_order_line_items.find_by(sadhak_profile: self)
      raise "#{syid} is already applied for this event with Reference Number: #{line_item.try(:event_order).try(:reg_ref_number)} " if line_item.present? and line_item.try(:event_order).try(:pending?)
      raise "#{syid} is already applied for this event and the application has been approved by Ashram." if line_item.present? and line_item.try(:event_order).try(:approve?)
      raise "#{syid} is already applied for this event but the application is not accepted, you may try next time. " if line_item.present? and line_item.try(:event_order).try(:rejected?)
    end

    # Check for Ashram Residential Shivirs
    if event.is_ashram_residential_shivir?
      raise "SYID: #{syid} is only allowed to apply for residential shivirs once every 6 months." if EventOrderLineItem.joins(event: [:event_type]).where('event_order_line_items.sadhak_profile_id = ? AND event_order_line_items.created_at > ? AND event_order_line_items.created_at <= ? AND event_types.name = ?', id, (Time.zone.now - 6.months).beginning_of_day, Time.zone.now, ASHRAM_RESIDENTIAL_SHIVIR).exists?
    end

    raise "Photo Id/Profile Photo is not approved for SYID: #{syid}." unless pp_success? && pi_success? if event.is_photo_proof_required?

    raise "Sadhak is not eligible to register this event. Sadhak must be #{event.min_age_criteria.to_i} years old." if (event.is_in_india? && event.min_age_criteria.to_i > 0) && !has_age_eligibility_to_register_on?(event)

  end

  def attended_event_types
    events.pluck(:event_type_id).uniq
  end

  def has_attended_farmer_shivir
    return false if !(farmer_shivir = GlobalPreference.get_value_of('farmer_event_types').to_s.split(',').map(&:to_i)).present?
    (farmer_shivir - attended_event_types) != farmer_shivir
  end

  def accessable_shivir_episodes
    collection_ids = SadhakAssetAccessAssociation.live_shivir_episode_accesses.select{|access| access.sadhak_profile_ids.split(',').map(&:upcase).include?(self.syid)}.pluck(:collection_id).uniq
    episodes = DigitalAsset.where(collection_id: collection_ids)
  end

  def can_view_shivir_collection
    can_view = SadhakAssetAccessAssociation.live_shivir_episode_accesses.pluck(:sadhak_profile_ids).map{|s| s.split(',')}.flatten.map(&:upcase).include?(self.syid) || false
  end

  def has_shivir_episode_upload_access?
    GlobalPreference.get_value_of('shivir_episode_upload_admin').to_s.split(',').map(&:upcase).include?(syid) || false
  end

  def is_shivir_episode_access_admin?
    GlobalPreference.get_value_of('shivir_episode_access_admin').to_s.split(',').map(&:upcase).include?(syid) || false
  end

  def weekly_sadhak_profiles_details(params = {})
    begin

      recipients = (params[:recipients].try(:split, ',').try(:extract_valid_emails).try(:uniq) || [])

      raise "Please provide valid emails." if params[:recipients].present? && !recipients.present?

      raise "User not found" unless user

      sync = false

      t_config = {file_name: 'weekly_sadhak_profiles_details', prefix: "#{ENV['ENVIRONMENT']}/search_sadhak", template: 'search_sadhak_result', sync: sync}
      task = Task.new(taskable_id: user.try(:id), taskable_type: 'User', email: recipients.join(','), opts: { batch_size: 10000 }, t_config: t_config)

      raise SyException, task.errors.full_messages.first unless task.save

      task.add_start_block do |parent_task, params = {}|

        raise ArgumentError.new('Parent task cannot be blank.') unless parent_task.present?

        search_results = SadhakProfile.order(:id).includes({ address: [:db_city, :db_state, :db_country] }).pluck(:id)

        raise SyException, 'No sadhak profile found, Try searching with some other criteria.' unless search_results.present?

        parent_task.result = search_results
      end

      task.add_final_block do |sub_task, sadhak_profile_ids, opts = {}|

        raise ArgumentError.new('Sub task cannot be blank.') unless sub_task.present?

        sadhak_profiles = SadhakProfile.where(id: sadhak_profile_ids).includes({ address: [:db_city, :db_state, :db_country] }).order(:id)

        # Generate profiles data.
        data = GenerateSadhakProfilesExcel.call(sadhak_profiles, opts[:status])

        file = sub_task.generate_excel_file(data.merge({data_type: opts[:sync] ? nil : 'file'}))

        sub_task.result = {file: file, from: sadhak_profiles.first.id, to: sadhak_profiles.last.id, format: 'xls'}
      end

      task.delay.create_subtasks

    rescue SyException => e
      notify_exception(e)
      logger.info("Manual Exception in weekly_sadhak_profiles_details Method: #{e.message}")
    rescue Exception => e
      notify_exception(e)
      logger.info("Runtime Exception in weekly_sadhak_profiles_details Method: #{e.message}")
    end
  end

  def accessible_shivir_type_episodes
    collection_event_type_associations = CollectionEventTypeAssociation.joins(:collection).where(collections: { collection_type: Collection.collection_types[:shivir] }).where.not(sadhak_profile_ids: [nil, ""]).select{ |association|
      association.sadhak_profile_ids.try(:split, ",").try(:map, &:upcase).try(:include?, self.syid) && Event.where("creator_user_id = ? AND event_type_id = ? AND (event_start_date::date <= ? AND event_end_date::date >= ?)", user.try(:id), association.event_type_id, Time.now + 4.days, Time.now - 3.days).count > 0
    }

    DigitalAsset.where(collection_id: collection_event_type_associations.try(:pluck, :collection_id)).where("digital_assets.published_on <= :current_date AND digital_assets.expires_at >= :current_date", { current_date: Date.today })
  end

  def active_club_membership
    forum_memberships.approve.first
  end

  def has_age_eligibility_to_register_on?(event)
    # Check Age criteria if event in india
    age >= event.min_age_criteria.to_i if (event.is_in_india? && event.min_age_criteria.to_i > 0)
  end

  private

  def date_of_birth_changed?
    date_of_birth != SadhakProfile.find_by_id(id).try(:date_of_birth)
  end

  # Method to check whenther the profile is under age or not whenever user changes their date of birth
  def validate_under_age
    self.is_under_age = (self.age < SADHAK_MIN_AGE)
    errors.empty?
  end

  def format_phone
    return if mobile.blank?
    self.mobile = Utilities::Mobile.new(mobile, country_ISO2).parsed_number
  end

  def mobile_or_email_is_present
    return if mobile.present? || email.present?
    errors.add :base, 'Mobile or Email must be provided'
  end

end
