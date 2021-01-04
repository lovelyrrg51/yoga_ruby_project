class SyClub < ApplicationRecord
  extend FriendlyId
  friendly_id :generate_sy_club_slug, use: [:slugged, :finders]

  # Lat Long - 0.09 decimal degree equal to approx 10 KM.
  DEFAULT_RANGE = 0.09
  CONTENT_TYPE = ["english", "hindi"]
  REQUIRED_FIELD_FOR_BASIC_PROFILE = [:name, :members_count, :content_type]
  NO_OF_SY_CLUB_REFERENCES = 3
  SYID = "syid"
  FORUM_ID = "forum_id"
  REGISTRATION_DATE = "registration_date"

  attr_accessor :status_notes
  belongs_to :user, optional: true
  has_one :address, as: :addressable, dependent: :destroy
  has_one :sy_club_venue_detail, dependent: :destroy
  has_one :sy_club_digital_arrangement_detail, dependent: :destroy
  has_many :sy_club_sadhak_profile_associations, dependent: :destroy
  has_many :sadhak_profiles, through: :sy_club_sadhak_profile_associations
  has_many :sy_club_user_roles, through: :sy_club_sadhak_profile_associations
  has_many :sy_club_references, dependent: :destroy
  has_many :sadhak_profile_references, through: :sy_club_references, source: :sadhak_profile
  has_many :sy_club_members, dependent: :destroy
  has_many :members, through: :sy_club_members, source: :sadhak_profile
  has_many :approved_members, lambda { where(sy_club_members: {status: SyClubMember.statuses['approve'], is_deleted: false}).where.not(sy_club_members: {event_registration_id: nil}) }, through: :sy_club_members, source: :sadhak_profile
  has_many :sy_club_event_associations, dependent: :destroy
  has_many :events, through: :sy_club_event_associations
  has_many :sy_club_event_type_associations, dependent: :destroy
  has_many :event_types, through: :sy_club_event_type_associations
  has_one :event_order
  # has_many :sy_club_payment_gateway_associations
  # has_many :payment_gateways, :through => :sy_club_payment_gateway_associations
  has_many :stripe_subscriptions
  has_many :tickets, as: :ticketable, dependent: :destroy
  has_many :shivyog_change_logs, as: :change_loggable, dependent: :destroy
  has_many :forum_attendance_details

  default_scope { where(is_deleted: false) }

  scope :sy_club_id, lambda { |sy_club_id| where(id: sy_club_id) }
  scope :country_id, ->(country_id) { joins(:address).where('country_id = ?', country_id) }
  scope :state_id, ->(state_id) { joins(:address).where('state_id = ?', state_id) }
  scope :city_id, ->(city_id) { joins(:address).where('city_id = ?', city_id) }
  scope :lat, ->(lat) { joins(:address).where('addresses.lat >= ? AND addresses.lat <= ?', (lat.to_f - DEFAULT_RANGE), (lat.to_f + DEFAULT_RANGE) ) }
  scope :lng, ->(lng) { joins(:address).where('addresses.lng >= ? AND addresses.lng <= ?', (lng.to_f - DEFAULT_RANGE), (lng.to_f + DEFAULT_RANGE) ) }
  scope :sy_club_name, ->(sy_club_name) { where('sy_clubs.name ILIKE ?', "%#{sy_club_name.strip}%") }
  scope :status, ->(status) { where('sy_clubs.status = ?', SyClub.statuses[status]) }
  scope :active_global, -> do
    joins(:address)
      .where.not(
        addresses: { country_id: [113, nil] },
        status: SyClub.statuses["disabled"]
      ).order(id: :asc)
  end
  scope :active_india, -> do
    joins(:address)
      .where(addresses: { country_id: 113 })
      .where.not(status: SyClub.statuses["disabled"])
      .order(id: :asc)
  end

  auto_strip_attributes :name, :email
  validates :name, presence: true, length: { minimum: 3 }
  validates_uniqueness_of :name, conditions: lambda { where(is_deleted: false) }
  # validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: 'please enter a valid email id'
  validates :members_count, :min_members_count, presence: true
  validates_numericality_of :members_count, :only_integer => true, :greater_than_or_equal_to => Proc.new{|sy_club| sy_club.min_members_count}
  validates_numericality_of :min_members_count, :only_integer => true, :greater_than_or_equal_to => 0
  enum club_level: { subcity: 5, city: 4, state: 3, country: 2, global: 1}
  before_save :track_status_changes
  before_save :is_min_members_count_changed
  after_initialize :define_sy_club_role_methods
  after_commit :forum_creation_email, on: :create

  delegate :full_address, to: :address, :allow_nil => true
  delegate :country_telephone_prefix, to: :address, :allow_nil => true
  delegate :state_name, to: :address, allow_nil: true
  delegate :city_name, to: :address, allow_nil: true

  accepts_nested_attributes_for :address, :allow_destroy => true
  accepts_nested_attributes_for :sy_club_sadhak_profile_associations, :allow_destroy => true
  accepts_nested_attributes_for :sy_club_venue_detail, :allow_destroy => true
  accepts_nested_attributes_for :sy_club_digital_arrangement_detail, :allow_destroy => true
  accepts_nested_attributes_for :sy_club_references, :allow_destroy => true

  include AASM
  enum status: { enabled: 0, disabled: 1, capacity_reached: 2 }
  aasm column: :status, enum: true do
    state :enabled, initial: true
    state :disabled
    state :capacity_reached

    event :disabled do
      transitions from: :enabled, to: :disabled
    end

    event :capacity_reached do
      transitions from: :enabled, to: :capacity_reached
    end
  end

  def define_sy_club_role_methods

    class << self

      SyClubUserRole.find_each do |role|
        define_method(role.role_name.downcase.to_sym){
          sy_club_sadhak_profile_associations.where(sy_club_user_role_id: role.id).last.try(:sadhak_profile)
        }
      end

    end

  end

  def is_min_members_count_changed
    if min_members_count_was != min_members_count
      errors.add(:error, 'You are not authorized to update minimum members count. Please contact to Ashram.') unless $current_user.present? and ($current_user.super_admin? or $current_user.club_admin?)
    end
    errors.empty?
  end

  def active_members_count
    self.approved_members.size
  end

  def nearest_non_member_sadhaks
    SadhakProfile.non_banned_sadhaks.joins(:address).where("addresses.city_id = ? AND sadhak_profiles.id NOT IN (?)", address.city_id, approved_members.ids)
  end

  def forum_members_report(_ids = nil)
    begin
      # If sy_club_ids recieved as argument then it will be comma seperated forum ids
      sy_club_ids = _ids.try(:split, ',')

      columns_for_member_list = %w(SYID FULLNAME MOBILE EMAIL EXPIRATION_DATE)

      if sy_club_ids.present?
        sy_clubs = SyClub.where(status: SyClub.statuses['enabled'], id: sy_club_ids).includes(:approved_members, { address: [:db_city, :db_state, :db_country] }, :sadhak_profiles, {sy_club_sadhak_profile_associations: [:sadhak_profile]}).order('id ASC')
      else
        sy_clubs = SyClub.where(status: SyClub.statuses['enabled']).includes(:approved_members, { address: [:db_city, :db_state, :db_country] }, :sadhak_profiles, {sy_club_sadhak_profile_associations: [:sadhak_profile]}).order('id ASC')
      end

      sy_clubs.find_each(batch_size: 1).each do |club|

        members_count = club.approved_members.size

        # Forum members list
        recipients = club.sy_club_sadhak_profile_associations.select{|a| a.sy_club_user_role_id != nil}.collect{|s| s.sadhak_profile.try(:email) }.uniq
        recipients += ENV['DEVELOPMENT_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'development'
        recipients += ENV['TESTING_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'testing'
        recipients = recipients.extract_valid_emails

        if recipients.count > 0 and members_count > 0
          members_list = Array.new
          club.sy_club_members.where(sy_club_members: {status: SyClubMember.statuses['approve'], is_deleted: false}).includes(:sadhak_profile, :event_registration).each do |member|
            sp = member.sadhak_profile
            reg = member.event_registration
            row = [sp.try(:syid), sp.try(:full_name).try(:titleize), sp.try(:mobile), sp.try(:email)]
            row.push("#{(reg.created_at.to_date + reg.expires_at.to_i - 1).strftime('%b %d, %Y')} at 23:59") rescue nil
            members_list.push(row)
          end

          attachments = {}

          attachments["forum_#{club.id}_members_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"] = GenerateExcel.generate(rows: members_list, header: columns_for_member_list)

          data = club.generate_renewal_registration_excel

          if data[:rows].size > 0
            attachments["forum_#{club.id}_renewal_members_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"] = GenerateExcel.generate(data)
          end

          begin
            from = GetSenderEmail.call(club)
            ApplicationMailer.send_email(from: from, recipients: recipients, subject: "#{club.name.try(:titleize)} Members List - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", template: 'forum_members_list', attachments: attachments, total_members_count: members_count, club: club).deliver
            logger.info("Forum members list and renewal members list sent to - #{recipients.to_sentence} for forum - #{club.id}")
          rescue => e
            Rollbar.error(e)
          end
        end
      end
    rescue => e
      Rollbar.error(e)
    end
  end

  def track_status_changes
    if self.status_changed?
      # Params order
      # attribute_name, value_before, value_after, description, change_loggable_id, change_loggable_type
      self.create_change_log('status', self.status_was, self.status, self.status_notes);
    end
  end

  ## To assign validity window after successful payment
  def after_club_payment(payment, message, payment_detail_params)
    @sy_club_validity_window_id = payment_detail_params[:sy_club_validity_window_id]
    @association_ids =  payment_detail_params[:association_ids]
    @guest_email = payment_detail_params[:guest_email]
    is_update_success = false
    sadhak_profiles = []
    members_email = []
    club = SyClub.includes(:sy_club_sadhak_profile_associations, :sadhak_profiles, :sy_club_members).find_by_id(payment_detail_params[:sy_club_id])
    club_admins = club.sy_club_sadhak_profile_associations.select{|a| a.sy_club_user_role_id != nil}
    sadhak_profile_ids = club_admins.collect{|s| s.sadhak_profile_id} + club.sy_club_members.where('virtual_role != ?', nil).collect{|s| s.sadhak_profile_id}
    organizers_email = SadhakProfile.where(id: sadhak_profile_ids).pluck('DISTINCT email')
    if !message.present?
      gateway = TransferredEventOrder.gateways.find{|g| g[:model] == payment.class.to_s}
      begin
        ApplicationRecord.transaction do
          if @association_ids.count > 0
            SyClubMember.where(id: @association_ids).each do |association|
              if association.update(status: 'approve', sy_club_validity_window_id: @sy_club_validity_window_id, guest_email: @guest_email, club_joining_date: DateTime.now, transaction_id: payment.try(gateway[:transaction_id].to_sym), payment_method: gateway[:payment_method])
                is_update_success = true
                sadhak_profiles.push(association.sadhak_profile)
                members_email.push(association.sadhak_profile.email)
                notify_registration(association)
              else
                raise RuntimeError.new("some error occured while updating your profile.")
              end
            end
          end
        end
        begin
          # Send forum payment confirmation email to guest email and registered profiles
          from = GetSenderEmail.call(club)
          ApplicationMailer.send_email(from: from, recipients: ([@guest_email] + members_email), subject: "Forum (#{club.name}) payment has been received ##{sadhak_profiles.collect{|s| s.syid}.join(",")} - #{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}", template: 'club_joining_confirmation', payment: payment, sadhak_profiles: sadhak_profiles).deliver if ([@guest_email] + members_email).size > 0 rescue "Some error occured while sending emails to members #{club.id}-#{([@guest_email] + members_email)}."

          # Send forum payment confirmation email to forum organisers
          ApplicationMailer.send_email(from: from, recipients: organizers_email, subject: "Forum (#{club.name}) payment has been received ##{sadhak_profiles.collect{|s| s.syid}.join(",")} - #{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}", template: 'club_joining_confirmation', payment: payment, sadhak_profiles: sadhak_profiles).deliver if organizers_email.size > 0 rescue "Some error occured while sending emails to organisers forum id #{club.id}-#{organizers_email}."

        rescue Exception => e
          logger.info(e)
          logger.info("Error in sending Email.")
        end
      rescue Exception => e
        logger.info(e)
        err_message = e.message
        is_update_success = false
      end
    end
    return is_update_success, err_message
  end

  def check_for_already_paid(association_ids)
    message = nil
    self.sy_club_members.where(id: association_ids).each do |member|
      if member.status == "approve"
        message = "Profile: #{member.try(:sadhak_profile).try(:full_name)}-#{member.try(:sadhak_profile).try(:syid)} is already paid."
        break
      end
    end
    message
  end

  def notify_registration(member_association)
    if member_association.status == 'approve' and member_association.sadhak_profile.present?
      begin
        sadhak_profile = member_association.sadhak_profile
        if sadhak_profile.address.present?
          address = sadhak_profile.address
          telephone_prefix = DbCountry.find(address.country_id).telephone_prefix
          country_code = DbCountry.find(address.country_id).ISO2
          if sadhak_profile.mobile.present?
            res = SendSms.call(sadhak_profile.mobile, telephone_prefix, "#{member_association.sy_club.name}-registration success with transaction id: " + member_association.transaction_id + "\nSYID: " + member_association.sadhak_profile.syid, country_code.to_s)
            if message.present?
              logger.info(message)
            end
          end
        else
          logger.info("address not found")
        end
      rescue Exception => e
        logger.info(e)
      end
    end
  end

  def self.preloaded_data
    self.includes(
      { address: [:db_city, :db_state, :db_country] },
      :sadhak_profile_references,
      { sy_club_sadhak_profile_associations: [:sy_club_user_role, :sy_club_validity_window] },
      { sadhak_profiles: [:forum_memberships] },
      :events,
      :event_types,
      :sy_club_venue_detail,
      :sy_club_digital_arrangement_detail,
      :approved_members
    )
  end

  # method to find registration which are going to be expire
  def generate_renewal_registration_excel
    begin
      header = %w(SYID FULL_NAME REG_REF_NUMBER EXPIRES_AT DAYS_LEFT REGISTRATION_STATUS MEMBERSHIP_RENEWAL_LINK)
      rows = []

      india_event_ids = GlobalPreference.get_value_of('india_clp_events').to_s.split(',')

      global_event_ids = GlobalPreference.get_value_of('global_clp_events').to_s.split(',')

      global_renewal_link = GlobalPreference.get_value_of('global_clp_renewal_link').to_s

      india_renewal_link = GlobalPreference.get_value_of('india_clp_renewal_link').to_s

      SyClubMember.joins(:event_registration).where(event_registrations: {event_id: (india_event_ids + global_event_ids)}, sy_club_members: {status: SyClubMember.statuses['approve'], sy_club_id: self.id}).where.not(sy_club_members: {event_registration_id: [nil]}).includes({event_registration: [:sadhak_profile, :event_order]}).each do |member|

        reg = member.event_registration

        sadhak_profile = reg.try(:sadhak_profile)

        days = reg.try(:get_remaining_days)

        if india_event_ids.include?(reg.event_id.to_s)
          link = "#{india_renewal_link}/#{member.sy_club_id}/register"
        elsif global_event_ids.include?(reg.event_id.to_s)
          link = "#{global_renewal_link}/#{member.sy_club_id}/register"
        else
          link = 'NA'
        end

        row = []

        if reg.present? and sadhak_profile.present? and days.present? and (1..30).include?(days)

          row.push(sadhak_profile.try(:syid))

          row.push(sadhak_profile.try(:full_name))

          row.push(reg.try(:event_order).try(:reg_ref_number))

          row.push("#{(reg.created_at.to_date + reg.expires_at.to_i - 1).strftime('%b %d, %Y')} at 23:59")

          row.push(days - 1)

          row.push(EventOrder.template_status_mapper[reg.try(:status)])

          row.push(link)

          rows.push(row)
        end
      end

    rescue => e
      logger.info("Something went wrong in method: generate_renewal_registration_excel, error: #{e.message}")
      Rollbar.error(e)
    end

    return {header: header, rows: rows}
  end

  # To get board member emails
  def board_member_emails
    self.sy_club_sadhak_profile_associations.collect{|association| association.sadhak_profile.present? ? association.sadhak_profile.email : nil}.extract_valid_emails
  end

  # Check whether a sadhak is board member or not
  def is_board_member?(sadhak_profile_id)
    self.sy_club_sadhak_profile_associations
      .where.not(sy_club_user_role_id: nil)
      .exists?(sadhak_profile_id: sadhak_profile_id.to_i)
  end

  def check_transfer(forum_transfer_params = {})
    success = []
    requested_seats = 0

    # Get forum details
    sy_club = self
    raise SyException, "#{sy_club.name} forum is not active. Please contact to board members." unless sy_club.enabled?

    banned_sadhak_ids = (GlobalPreference.get_value_of('banned_forum_sadhaks').try(:split, ',') || []).map{|v| v[/-?\d+/].to_i}

    event = Event.find(forum_transfer_params[:event_id])

    raise SyException, "Event not found with id: #{forum_transfer_params[:event_id]}." unless event.present?
    raise SyException, "#{event.event_name} address not found." unless event.address.present?
    raise SyException, "#{sy_club.name} forum address not found." unless sy_club.address.present?

    # To get value of india and global events
    india_event_ids = GlobalPreference.get_value_of('india_clp_events').to_s.split(',')
    global_event_ids = GlobalPreference.get_value_of('global_clp_events').to_s.split(',')

    # Validate india event
    if event.address.country_id == 113
      raise SyException, "#{event.event_name} event does not belong to india events." unless india_event_ids.include?(event.id.to_s)
      raise SyException, "Forum country #{sy_club.address.try(:country_name)} mismatch with event country #{event.address.try(:country_name)}" if sy_club.address.try(:country_id) != 113
    else
      raise SyException, "#{event.event_name} event does not belong to global events." unless global_event_ids.include?(event.id.to_s)
    end

    # To ensure that all sadhak belongs to India only or outside only.
    sadhak_profiles = SadhakProfile.where(id: forum_transfer_params[:sadhak_profiles].collect{|s| s.syid})
    raise SyException, 'Sadhak Profile(s) not found.' unless sadhak_profiles.present?

    event_registrations = EventRegistration.where(event_id: (india_event_ids + global_event_ids), sadhak_profile_id: sadhak_profiles.pluck(:id), status: EventRegistration.valid_registration_statuses).includes(:sy_club_member)

    sy_club_member_action_details = SyClubMemberActionDetail.where(status: SyClubMemberActionDetail.statuses['approved'], sadhak_profile_id: sadhak_profiles.pluck(:id), action_type: SyClubMemberActionDetail.action_types['transfer'])

    # Verify that sadhak profiles already registered for this forum.
    forum_transfer_params[:sadhak_profiles].each do |ui_profile|

      profile = sadhak_profiles.find{|sp| sp.id == ui_profile.syid.to_i}
      raise SyException, "Sadhak Profile not found with SYID: #{ui_profile[:syid]}" unless profile.present?

      raise SyException, "#{profile.syid} is not allowed to register/renew on #{sy_club.name}. Please contact Ashram." if banned_sadhak_ids.include?(profile.id)

      detail = {message: nil, syid: profile.syid, new_sy_club_id: sy_club.id}

      # To check old forum and new forum country
      registrations = event_registrations.select{|er| er.sadhak_profile_id == profile.id }

      raise SyException, "#{profile.syid} is registered on india as well as on global forum. Aborting." if registrations.size > 1

      event_registration = registrations.last

      if is_expired?(event_registration)
        event_registration.mark_expired
        event_registration = nil
      end

      detail[:event_registration_id] = event_registration.try(:id)

      sy_club_member = event_registration.try(:sy_club_member)

      detail[:sy_club_id] = sy_club_member.try(:sy_club_id)

      detail[:joining_date] = sy_club_member.try(:club_joining_date).try(:to_date).to_s

      detail[:sy_club_name] = (sy_club_member.try(:sy_club).try(:name) || '-')

      detail[:new_sy_club_name] = (sy_club.name || '-')

      detail[:expiration_date] = (event_registration.present? and sy_club_member.present?) ? event_registration.expiration_date : '-'

      raise SyException, "#{profile.syid} is not allowed to transfer on #{sy_club.name}" if event_registration.present? and event_registration.event_id != event.id

      detail[:transfer_attempts] = (event_registration.present? and sy_club_member.present?) ? sy_club_member_action_details.select{|sy_club_member_action_detail| sy_club_member_action_detail.sadhak_profile_id == profile.id and sy_club_member_action_detail.from_event_registration_id == event_registration.id}.size : 0

      detail[:can_renew] = (event_registration.present? and sy_club_member.present? and profile.renewal_events.include?(event))

      detail[:can_transfer] = (event_registration.present? and sy_club_member.present? and sy_club_member.sy_club_id != sy_club.id and (SyClubPolicy.new($current_user, sy_club).admin_transfer? || detail[:transfer_attempts] < FORUM_TRANSFER_LIMIT))

      raise SyException, "#{profile.syid} membership has been expired (#{event_registration.expiration_date}). So cannot processed. Remove it from list." if event_registration.present? and sy_club_member.present? and event_registration.get_remaining_days <= 0

      detail[:fresh_registration] = (event_registration.nil? and sy_club_member.nil?)

      if detail[:fresh_registration]
        detail[:message] = "#{profile.syid} is allowed to registered but not allowed to transfer and renew on #{sy_club.name}."
        requested_seats += 1
      elsif detail[:can_renew] and detail[:can_transfer]
        detail[:message] = "#{profile.syid} is allowed to transfer and renew on #{sy_club.name}."
        requested_seats += 1
      elsif detail[:can_renew]
        detail[:message] = "#{profile.syid} is allowed to renew on #{sy_club.name}."
      elsif detail[:can_transfer]
        detail[:message] = "#{profile.syid} is allowed to transfer on #{sy_club.name}."
        requested_seats += 1
      elsif not detail[:fresh_registration] and not detail[:can_renew] and not detail[:can_transfer] and sy_club.approved_members.include?(profile)
        detail[:message] = "#{profile.syid} is not allowed to renew or transfer on #{sy_club.name} because sadhak is already joined."
      end

      detail[:message] ||= '-'

      success.push(detail)

    end

    # Check that will block registration on forum if lesser seats available
    available = sy_club.members_count.to_i - sy_club.approved_members.size
    info_msg = available > 0 ? "Only #{available} seat(s) available." : 'No more seat(s) available. Please contact forum organisers.'
    raise SyException, "Forum #{sy_club.name} capacity is reached. #{info_msg.to_s}" if available < requested_seats

    can_transfer = success.collect{|s| s[:can_transfer]}.reduce(:&)

    can_renew = success.collect{|s| s[:can_renew]}.reduce(:&)

    fresh_registration = success.collect{|s| s[:fresh_registration]}.reduce(:&)

    {
      data: success,
      can_transfer: can_transfer,
      can_renew: can_renew,
      fresh_registration: fresh_registration
    }
  end


  def is_expired?(registration)
    registration.present? && registration.try(:sy_club_member).present? && registration.get_remaining_days <= 0
  end


  # Make sure that you are going to call this method with forum in which membership id going to transfer
  def do_transfer(data)
    success = []
    event_registrations = EventRegistration.where(id: data[:data].collect{|d| d[:event_registration_id]}).includes(:sy_club_member)
    sadhak_profiles = SadhakProfile.where(syid: data[:data].collect{|s| s[:syid]})

    ApplicationRecord.transaction do
      data[:data].each do |info|

        profile = sadhak_profiles.find{|sp| sp.syid == info[:syid]}
        raise SyException, "Sadhak profile not found with id: #{info[:syid]}" unless profile.present?
        sy_club = SyClub.find(info[:sy_club_id])

        raise SyException, "#{profile.syid} have reached maximum transfer capacity. Contact ashram for further support" unless SyClubPolicy.new($current_user, self).admin_transfer? or info[:transfer_attempts] < FORUM_TRANSFER_LIMIT

        event_registration = event_registrations.find{|er| (er.sadhak_profile_id == profile.id and EventRegistration.valid_registration_statuses.include?(EventRegistration.statuses[er.status]))}
        raise SyException, "Registration not found for SYID: #{profile.syid}" unless event_registration.present?

        line_item = event_registration.event_order_line_item
        raise SyException, "Line item not found for SYID: #{profile.syid}" unless line_item.present?

        old_sy_club_member = event_registration.try(:sy_club_member)

        raise SyException, "Old membership not found for SYID: #{profile.syid}" unless old_sy_club_member.present?

        raise SyException, "SYID: #{profile.syid} old membership is not approved." if SyClubMember.statuses[old_sy_club_member.status] != SyClubMember.statuses['approve']

        # Create a new member with new forum
        new_sy_club_member = self.sy_club_members.build(sadhak_profile_id: profile.id, status: SyClubMember.statuses['approve'], guest_email: data[:guest_email], transaction_id: "FORUM-TRANSFER-#{SecureRandom.base64(8).to_s}", event_registration_id: event_registration.id, metadata: "Transferred_from_member_id: #{old_sy_club_member.id}.", club_joining_date: Time.now)

        raise SyException, new_sy_club_member.errors.first unless new_sy_club_member.save

        # Create a entry in SyClubMemberActionDetail table to capture transfer requests
        sy_club_member_action_detail = SyClubMemberActionDetail.new(action_type: SyClubMemberActionDetail.action_types['transfer'], sadhak_profile_id: profile.id, from_sy_club_member_id: old_sy_club_member.id, to_sy_club_member_id: new_sy_club_member.id, from_event_registration_id: event_registration.id, to_event_registration_id: event_registration.id)

        raise SyException, "#{profile.syid} - #{sy_club_member_action_detail.errors.full_messages.first}" unless sy_club_member_action_detail.save

        raise SyException, sy_club_member_action_detail.error.full_messages.first unless sy_club_member_action_detail.approve!

        # Mark old membership as transferred and update transferred club id
        old_sy_club_member.update_columns(transferred_to_club_id: self.id, status: SyClubMember.statuses['transferred'], is_deleted: true, deleted_at: Time.now)

        success.push(syid: profile.syid, from_club: old_sy_club_member.sy_club.try(:name), to_club: self.name, expiration_date: "#{(event_registration.created_at.to_date + event_registration.expires_at - 1).strftime('%b %d, %Y')}", new_sy_club_member_id: new_sy_club_member.id, sy_club: sy_club)
      end
    end

    # Send transfer notifications
    send_transfer_notification(success)

    success
  end

  # Send email or sms about forum transfer to sadhaks
  def send_transfer_notification(success = [])
    guest_emails = []
    sadhak_profiles = SadhakProfile.where(syid: success.collect{|s| s[:syid]}).includes({ address: [:db_city, :db_state, :db_country]})
    new_sy_club_members = SyClubMember.where(id: success.collect{|s| s[:new_sy_club_member_id]})

    old_forum = success.collect{|sc| sc.sy_club}.first

    success.each do |info|

      profile = sadhak_profiles.find{|sp| sp.syid == info[:syid]}
      next unless profile.present?

      new_sy_club_member = new_sy_club_members.find{|m| m.id == info[:new_sy_club_member_id]}
      next unless new_sy_club_member.present?
      guest_emails.push(new_sy_club_member.guest_email)
      message = "NMS #{profile.syid}-#{profile.first_name}\nForum membership transferred successfully from #{info[:from_club]} to #{info[:to_club]}. Membership expiration date: #{info[:expiration_date]}."

      profile.delay.send_sms_to_sadhak(message) unless profile.email.to_s.is_valid_email? #if ENV['ENVIRONMENT'] == 'production'
    end
    begin
      from = GetSenderEmail.call(self)
      cc = sadhak_profiles.collect{|s| s.email}

      boards_member_emails = (old_forum.board_member_emails + self.board_member_emails)

      ApplicationMailer.send_email(from: from, recipients: guest_emails.uniq.extract_valid_emails, cc: cc, template: 'forum_transfer_confirmation', subject: "Forum Membership Transfer Confirmation", success: success).deliver

      ApplicationMailer.send_email(from: from, recipients: boards_member_emails, template: 'forum_transfer_confirmation', subject: "Forum Membership Transfer Confirmation", is_board_members: true, success: success).deliver if boards_member_emails.present?

    rescue Exception => e
      Rails.logger.info("Error occured while sending forum membership transfer email: #{e.message}")
    end
  end
  handle_asynchronously :send_transfer_notification

  # Method that will compute that all board members are active in any forum
  def has_board_members_paid
    has_paid = (self.sadhak_profiles.size >= 2)
    self.sadhak_profiles.each do |sp|
      has_paid &&= sp.active_club_ids.size > 0
      break unless has_paid
    end
    has_paid
  end

  def unpaid_board_members
    res = []
    if sadhak_profiles.size >= 2
      sadhak_profiles.each do |sp|
        if sp.active_club_ids.size <= 0
          res.push({
            first_name: sp.try(:first_name),
            last_name: sp.try(:last_name),
            full_name: sp.try(:full_name),
            syid: sp.try(:syid),
            role: sp.try(:board_member_position)
          })
        end
      end
    end
    res
  end

  def generate_sy_club_slug
    "#{SecureRandom.uuid}-#{SecureRandom.hex(3)}"
  end

  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end

  def basic_profile_completeness
    cal_completeness(SyClub::REQUIRED_FIELD_FOR_BASIC_PROFILE)
  end

  def is_basic_profile_completed?
    basic_profile_completeness.to_i == 100
  end

  def address_completeness
    address.cal_completeness(Address::REQUIRED_FIELD)
  end

  def is_address_complete?
    address && address_completeness == 100
  end

  def is_board_members_completed?
    SyClub.find(id).sy_club_sadhak_profile_associations.present?
  end

  def is_sy_club_references_completed?
    SyClub.find(id).sy_club_references.present?
  end

  def completed

    completed_percent = 0.00

    per_asso_weightage = 100.00/(4)

    completed_percent += 100.to_f * per_asso_weightage * 0.01 if is_basic_profile_completed?
    completed_percent += 100.to_f * per_asso_weightage * 0.01 if is_address_complete?
    completed_percent += 100.to_f * per_asso_weightage * 0.01 if is_board_members_completed?
    completed_percent += 100.to_f * per_asso_weightage * 0.01 if is_sy_club_references_completed?

    completed_percent

  end

  def clp_event
    address && address.country_name.try(:downcase) == INDIA.downcase ? Event.find_by_id(GlobalPreference.get_value_of('india_clp_events').to_s.split(',').first) :  Event.find_by_id(GlobalPreference.get_value_of('global_clp_events').to_s.split(',').first)
  end

  def ready_for_registrations
    address && enabled?
  end

  def membership_validity
    current_date = Date.today
    address && address.country_name.try(:downcase) == INDIA.downcase ? "#{current_date.strftime('%b %d, %Y')} - #{(current_date + GlobalPreference.get_value_of('india_clp_validity').to_i - 1).try(:strftime, "%b %d, %Y")}" : "#{current_date.strftime('%b %d, %Y')} - #{(current_date + GlobalPreference.get_value_of('global_clp_validity').to_i - 1).try(:strftime, "%b %d, %Y")}"
  end

  def forum_members_migration(filename, additional_details, recipients)
    begin
      @file = open(filename, "r")
      from = GetSenderEmail.call(self)

      result = []
      result_header = %w(SADHAK_PROFILE_ID CLUB_NAME CLUB_MEMBER_ID CLUB_REGISTRATION_ID MESSAGE)
      details = Hash.new
      file_name = 'offline-forum-members-migration'
      additional_details = additional_details.to_s

      recipients = recipients.present? ? recipients : %w(prince@metadesignsolutions.in)

      india_event_id = GlobalPreference.get_value_of('india_clp_events').to_s.split(',').first
      global_event_id = GlobalPreference.get_value_of('global_clp_events').to_s.split(',').first

      # We are moving data to clp product so it will automatic consider 1st seating category for data movement.
      india_event = Event.find(india_event_id)
      global_event = Event.find(global_event_id)

      event_seating_category_association = india_event.event_seating_category_associations.first
      seating_category_id = event_seating_category_association.seating_category_id #18
      event_seating_category_association_id = event_seating_category_association.id #98
      price = event_seating_category_association.price #50

      details[:india] = {seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price, event_id: event_seating_category_association.event_id, searchable_ids: [india_event_id, global_event_id]}

      event_seating_category_association = global_event.event_seating_category_associations.first
      seating_category_id = event_seating_category_association.seating_category_id #18
      event_seating_category_association_id = event_seating_category_association.id #98
      price = event_seating_category_association.price #50

      details[:global] = {seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price, event_id: event_seating_category_association.event_id, searchable_ids: [india_event.id, global_event.id]}

      excel_data = SyClub.read_xlsx(@file)

      raise "SYID column is missing in excel sheet." unless excel_data[:header].include?(SYID)
      raise "Forum ID column is missing in excel sheet." unless excel_data[:header].include?(FORUM_ID)
      raise "Registration Date column is missing in excel sheet." unless excel_data[:header].include?(REGISTRATION_DATE)

      errors = []
      error_header = []
      fresh = []
      renewals = []
      updates = []
      processed_sadhak_ids = []

      excel_data[:content].each do |r|

        begin

          r = r.with_indifferent_access

          syid = r[SYID].to_s[/-?\d+/].to_i

          sadhak_profile = SadhakProfile.find(syid)

          forum = SyClub.find(r[:forum_id])

          join_date = r[REGISTRATION_DATE].kind_of?(Date) ? r[REGISTRATION_DATE] : Date.parse(r[REGISTRATION_DATE])

          raise "SYID: #{sadhak_profile.syid} has invalid joining date" unless join_date.present?

          raise "Forum Address not present for #{forum.name}" unless forum.address.try(:country_id).present?

          detail = forum.address.try(:country_id) == 113 ? details[:india] : details[:global]

          registrations = EventRegistration.where(sadhak_profile_id: syid, event_id: detail[:searchable_ids], status: EventRegistration.valid_registration_statuses)

          raise "Multiple registrations found for sadhak profile id: #{syid} on CLP." if registrations.count > 1

          registration = registrations.last

          member = registration.try(:sy_club_member)

          if (sadhak_profile.renewal_events.collect(&:id).map(&:to_s) & detail[:searchable_ids]).size.nonzero?

            raise "Not allowed to renew sadhak id #{syid} on forum: #{forum.name}-#{forum.id} because syid is registered on #{member.sy_club.name}-#{member.sy_club_id}." unless registration.event_id == detail[:event_id]

            renewals << r.merge(syid: syid)

          elsif registration.present?

            updates << r.merge(syid: syid)

          else

            fresh << r.merge(syid: syid)

          end

          processed_sadhak_ids << syid

        rescue => exception

          errors << (r.values + [exception.message])

          error_header = (r.keys.map(&:upcase) + ['ERROR']) if error_header.size.zero?

        end

      end

      raise "Duplicate sadhak profile found." if processed_sadhak_ids.size != processed_sadhak_ids.uniq.size

      [fresh, renewals].each do |fresh_renewals|

        # Process Fresh Registrations
        fresh_renewals.group_by(&:forum_id).each do |forum_id, sadhaks|

          next if sadhaks.size.zero?

          forum = SyClub.find(forum_id)

          detail = forum.address.try(:country_id) == 113 ? details[:india] : details[:global]

          sadhaks.each_slice(10) do |_sadhaks|

            begin

              _success = []

              ActiveRecord::Base.transaction do

                event_order = EventOrder.new(event_id: detail[:event_id], guest_email: 'syitemails@gmail.com', is_guest_user: true, sy_club_id: forum.id)

                _sadhaks.each do |to_be_reg_member|

                  event_order.event_order_line_items.build(sadhak_profile_id: to_be_reg_member[SYID], seating_category_id: detail[:seating_category_id], event_seating_category_association_id: detail[:event_seating_category_association_id], price: detail[:price])

                end
                event_order.save!
                EventRegistration.without_callbacks(:notify_registration) do

                  cash_payment = PgCashPaymentTransaction.new(payment_date: Time.zone.now.to_date, is_terms_accepted: true, additional_details: additional_details, event_order_id: event_order.id)

                  cash_payment.save!

                  event_order.update!(sy_club_id: forum.id, status: EventOrder.statuses['success'], payment_method: 'Cash Payment', transaction_id: cash_payment.transaction_number)

                  event_order = event_order.reload

                  raise "Unable to create registrations." unless event_order.valid_event_registrations.exists?

                  event_order.valid_event_registrations.each do |registration|

                    r = _sadhaks.find{|s| s[:syid].to_i == registration.sadhak_profile_id }
                    # Message
                    message = 'Member created successfully.'

                    join_date = r[REGISTRATION_DATE].kind_of?(Date) ? r[REGISTRATION_DATE] : Date.parse(r[REGISTRATION_DATE])

                    member = registration.try(:sy_club_member)

                    # Calculate expiry at
                    expiry_days = 365

                    expiry_days -= (registration.created_at.try(:to_date) - join_date).to_i


                    old_expiry_days = registration.expires_at.to_i

                    if expiry_days > old_expiry_days
                      registration.update_columns(expires_at: expiry_days)
                    end

                    puts "SYID: #{member.sadhak_profile_id}, Registration ID: #{registration.id}, Member ID: #{member.id}"

                    _success.push([member.sadhak_profile_id, forum.name, member.id, registration.id, message])

                  end

                  cash_payment.update_columns(sy_club_id: forum.id, status: PgCashPaymentTransaction.statuses.approved, amount: detail[:price] * event_order.valid_event_registrations.count)

                end

                result += _success

              end

            rescue => exception

              _sadhaks.each do |s|

                errors << (s.values + [exception.message])

              end

            end

          end

        end

      end

      # Update existing registrations
      updates.group_by(&:forum_id).each do |forum_id, sadhaks|

        next if sadhaks.size.zero?

        forum = SyClub.find(forum_id)

        detail = forum.address.try(:country_id) == 113 ? details[:india] : details[:global]

        sadhaks.each_slice(10) do |_sadhaks|

          begin

            _success = []

            ActiveRecord::Base.transaction do

              _sadhaks.each do |to_be_reg_member|

                join_date = to_be_reg_member[REGISTRATION_DATE].kind_of?(Date) ? to_be_reg_member[REGISTRATION_DATE] : Date.parse(to_be_reg_member[REGISTRATION_DATE])

                is_expiry_days_updated = false

                registration = EventRegistration.where(sadhak_profile_id: to_be_reg_member[SYID], event_id: detail[:searchable_ids], status: EventRegistration.valid_registration_statuses).last

                member = registration.try(:sy_club_member)

                # Calculate expiry at
                expiry_days = 365

                expiry_days -= (registration.created_at.try(:to_date) - join_date).to_i

                old_expiry_days = registration.expires_at.to_i

                if expiry_days > old_expiry_days
                  is_expiry_days_updated = registration.update_columns(expires_at: expiry_days)
                end

                puts "SYID: #{member.sadhak_profile_id}, Registration ID: #{registration.id}, Member ID: #{member.id}, Is Expiry Days Updated: #{is_expiry_days_updated}"

                _success.push([member.sadhak_profile_id, forum.name, member.id, registration.id, "Is expiry days updated: #{is_expiry_days_updated} - Old expiry days: #{old_expiry_days} - Updated expiry days: #{expiry_days}"])

              end

              result += _success

            end

          rescue => exception

            _sadhaks.each do |s|

              errors << (s.values + [exception.message])

            end

          end

        end

      end

    rescue => e
      ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Error: Offline Forum Data Migration Result: File - #{file_name} Error Message- #{e.message}", template: "forum_data_migration_result" ).deliver
    end

    begin
      SyClub.last.generate_excel_and_upload(rows: errors, header: error_header, file_name: "#{file_name}-#{DateTime.now.strftime('%F %T')}-error.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/forum_data_migration/forum_members_migration") if errors.size.nonzero?
    rescue Exception => e
      puts "Error while uploading error file, error: #{e.message}."
    end

    begin
      SyClub.last.generate_excel_and_upload(rows: result, header: result_header, file_name: "#{file_name}-#{DateTime.now.strftime('%F %T')}-success.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/forum_data_migration/forum_members_migration") if result.size.nonzero?
    rescue Exception => e
      puts "Error while uploading success file, error: #{e.message}."
    end

    if recipients.present?
      begin
        attachments = {}
        attachments["#{file_name}-#{DateTime.now.strftime('%F %T')}-error.xls"] = GenerateExcel.generate(rows: errors, header: error_header) if errors.size.nonzero?
        attachments["#{file_name}-#{DateTime.now.strftime('%F %T')}-success.xls"] = GenerateExcel.generate(rows: result, header: result_header) if result.size.nonzero?
        ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Offline Forum Data Migration Result: File - #{file_name}", attachments: attachments, template: "forum_data_migration_result" ).deliver
      rescue => exception
        puts "Error while sending email."
      end
    end

    puts 'Process Completed.'
  end

  def forum_creation_email
    UserMailer.forum_creation_notify_board_members(self, true, nil).deliver_later
  end

  def send_updated_details
    UserMailer.forum_creation_notify_board_members(self, false, { is_board_member_updated: true }).deliver_later
  end

  def notify_all_nearest_non_forum_sadhaks
    sadhak_profiles = nearest_non_member_sadhaks
    UserMailer.notify_all_nearest_non_forum_members(sadhak_profiles, self)
  end

  def languages
    languages = content_type.to_s.split(',').map(&:downcase)
    return languages unless languages.empty?
    languages << address.country_id == 113 ? "hindi" : "english"
  end

end
