class Event < ApplicationRecord
  include AASM
  include Filterable

  extend FriendlyId
  friendly_id :generate_event_slug, use: [:slugged, :finders]

  has_paper_trail class_name: 'EventVersion', only: [:event_name, :event_start_date, :event_end_date, :creator_user_id, :cannonical_event_id, :event_proposal_id, :daily_start_time, :daily_end_time, :description, :graced_by, :contact_details, :video_url, :demand_draft_instructions, :status, :event_type_id, :payment_category, :total_capacity, :contact_email, :website, :event_start_time, :event_end_time, :additional_details, :venue_type_id, :is_photo_proof_required, :show_seats_availability, :event_location, :status_changes_notes, :master_event_id, :is_club_event, :pre_approval_required, :registrations_recipients, :show_shivir_price, :full_profile_needed, :pay_in_usd, :entity_type, :entity_key, :event_cancellation_plan_id, :discount_plan_id, :automatic_refund, :sy_event_company_id, :reference_event_id, :has_seva_preference, :approver_email, :logistic_email, :end_date_ignored, :prerequisite_message, :notification_service, :shivir_card_enabled, :discount_text], skip: [], on: [:update, :destroy]

  # Event Replication
  amoeba do

    set status: 'proposed'

    nullify :event_start_date

    nullify :event_end_date

    customize([
      lambda do |orig_obj, copy_of_obj|
        copy_of_obj.event_name = "Copy of #{copy_of_obj.event_name} #{Time.zone.now.strftime('%d%m%Y%H%M%S%6N')}"
        copy_of_obj.creator_user_id = $current_user.try(:id)
        copy_of_obj.slug = nil
      end
    ])

    include_association :event_seating_category_associations
    include_association :event_tax_type_associations
    include_association :event_payment_gateway_associations
    include_association :event_prerequisites_event_types
    include_association :event_team_details
    include_association :event_digital_asset_associations
  end

  scope :sy_club_id, ->(sy_club_id) { joins(:sy_clubs).where('sy_club_event_associations.sy_club_id = ?', sy_club_id) }
  scope :event_type_id, ->(event_type_id) { where event_type_id: event_type_id }
  scope :country_id, ->(country_id) { joins(:address).where('country_id = ?', country_id) }
  scope :state_id, ->(state_id) { joins(:address).where('state_id = ?', state_id) }
  scope :city_id, ->(city_id) { joins(:address).where('city_id = ?', city_id) }
  scope :entity_type, ->(entity_type) { where entity_type: Event.entity_types[entity_type.to_s] }
  scope :event_end_date, ->(event_end_date) { where('event_end_date >= ?', event_end_date) }
  scope :status, ->(status) { where(status: Event.statuses.select{|k, v| status.to_s.split(',').include?(k.to_s) }.values) }
  scope :graced_by, ->(graced_by) { where(graced_by: graced_by) }
  scope :from_date, ->(from_date) { where('created_at >= ?', from_date) }
  scope :to_date, ->(to_date) { where('created_at <= ?', to_date) }
  scope :ordered, ->(ordered) { order(Event.column_names.include?(ordered) ? ordered : 'event_start_date') }
  scope :event_start_date, ->(event_start_date) { where('events.event_start_date >= ?', event_start_date) }
  # validates :event_start_date, presence: true, :if => event_date_tbd = false
  # validates :event_end_date, presence: true, date: { :after_or_equal_to => :event_start_date, :message => " must be after start date"}
  validates :event_name, uniqueness: { scope: :event_start_date,
    message: "should not be same on same date" }
  validates_numericality_of :min_age_criteria, allow_nil: true
  validates :event_location, presence: true
  enum payment_category: {paid: 1, free: 0}

  has_many :event_references
  has_many :event_sponsors
  has_many :event_orders
  has_many :event_order_line_items, through: :event_orders, source: :event_order_line_items
  has_many :event_registrations

  has_many :valid_event_registrations, lambda { where(event_registrations: {status: EventRegistration.valid_registration_statuses})}, class_name: 'EventRegistration'
  has_many :registered_sadhak_profiles, through: :valid_event_registrations, source: :sadhak_profile
  has_many :vaild_registered_sadhak_profiles, through: :valid_event_registrations, source: :sadhak_profile

  has_many :sadhak_profiles, through: :event_registrations
  has_many :event_seating_category_associations, inverse_of: :event
  has_many :seating_categories, through: :event_seating_category_associations
  has_many :event_awarenesses
  has_many :event_tax_type_associations, inverse_of: :event
  has_many :tax_types, through: :event_tax_type_associations
  belongs_to :creator_user, class_name: 'User', foreign_key: 'creator_user_id', optional: true
  belongs_to :venue_type, optional: true
  belongs_to :cannonical_event, optional: true
  belongs_to :event_type, optional: true
  has_one :pandal_detail
  has_one :bhandara_detail
  has_many :event_cost_estimations
  has_many :attachments, ->{ order('id DESC').limit(1) }, as: :attachable
  # has_one :attachment
  has_many :tickets, as: :ticketable
  has_one :address, as: :addressable, dependent: :destroy, inverse_of: :addressable
  has_one :reference_event, class_name: "Event", foreign_key: "reference_event_id"
  has_many :event_registration_center_associations, dependent: :destroy
  has_many :registration_centers, through: :event_registration_center_associations
  has_many :event_team_details, dependent: :destroy
  has_many :event_payment_gateway_associations, inverse_of: :event
  has_many :payment_gateways, through: :event_payment_gateway_associations#, dependent: :destroy
  has_many :payment_gateway_types, through: :payment_gateways
  has_many :ds_shops
  has_many :event_digital_asset_associations, inverse_of: :event
  has_many :digital_assets, :through => :event_digital_asset_associations
  has_many :handy_attachments, lambda { where(attachments: {attachable_type: "HandyAttachment"}).order('id DESC').limit(1) }, class_name: "Attachment", foreign_key: "attachable_id"
  # has_one :handy_attachment
  # for prerequisites events
  has_many :prerequisite_events, class_name: 'Event', foreign_key: :master_event_id
  belongs_to :master_event, class_name: 'Event', optional: true
  has_many :event_prerequisites_event_types, dependent: :destroy, inverse_of: :event
  has_many :event_types, through: :event_prerequisites_event_types
  has_many :sy_club_event_associations
  has_many :sy_clubs, through: :sy_club_event_associations
  has_many :activity_event_type_pricing_associations, dependent: :destroy
  has_many :event_type_pricings, through: :activity_event_type_pricing_associations
  belongs_to :sy_event_company, optional: true
  belongs_to :event_cancellation_plan, optional: true

  has_many :event_discount_plan_associations
  has_many :discount_plans, through: :event_discount_plan_associations
  belongs_to :discount_plan, optional: true

  belongs_to :event_cancellation_plan, optional: true
  has_many :requested_payment_refunds, ->{ PaymentRefund.requested },
    class_name: 'PaymentRefund', foreign_key: 'event_id'
  has_many :payment_refunds, dependent: :destroy
  has_many :event_cancellation_plan_items, through: :event_cancellation_plan

  #to validate whether current event should not be there in discount ploicy
  before_save :validate_discount_plan
  belongs_to :sy_event_company, optional: true
  has_many :event_order_line_items, through: :event_orders

  delegate :full_address, to: :address, allow_nil: true
  delegate :name, to: :event_type, allow_nil: true, prefix: true
  delegate :street_address, to: :address, allow_nil: true
  delegate :country_name, to: :address, allow_nil: true
  delegate :country_id, to: :address, allow_nil: true
  delegate :state_name, to: :address, allow_nil: true
  delegate :city_name, to: :address, allow_nil: true
  delegate :city_name, to: :address, allow_nil: true
  delegate :country_currency_code, to: :address, allow_nil: true
  delegate :country_telephone_prefix, to: :address, allow_nil: true
  delegate :country_ISO2, to: :address, allow_nil: true
  delegate :postal_code, to: :address, allow_nil: true

  scope :upcoming, -> do
    where.not(id: Event.clp_event_ids)
      .where(status: [:test_registration, :ready])
      .where('event_start_date > ?', Date.current)
      .order(event_start_date: :asc)
  end

  scope :ongoing, -> do
    where.not(id: Event.clp_event_ids)
      .where(status: [:test_registration, :ready])
      .where('event_start_date <= ? AND event_end_date >= ?', Date.current, Date.current)
  end

  after_initialize :set_event_meta_type

  def set_event_meta_type
    self.cannonical_event_id = CannonicalEvent.first&.id unless self.cannonical_event_id.present?
  end

  def handy_attachment
    self.handy_attachments.sort.last
  end

  def attachment
    self.attachments.sort.last
  end

  accepts_nested_attributes_for :address, allow_destroy: true
  accepts_nested_attributes_for :event_tax_type_associations, reject_if: ->(attrs) { attrs['tax_type_id'].blank? || attrs['percent'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :event_payment_gateway_associations, reject_if: ->(attrs) { attrs['event_id'].blank? || attrs['payment_gateway_id'].blank? || attrs['payment_start_date'].blank?|| attrs['payment_end_date'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :event_seating_category_associations, allow_destroy: true
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :handy_attachments, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :prerequisite_events
  accepts_nested_attributes_for :event_types

  after_validation :validate_format_of_registrations_recipients
  after_create :create_bhandara_details
  after_save :after_event_save
  # after_create :assign_ds_shop_to_event
  after_create :assign_master_event_id
  after_create :assign_seating_category

  enum entity_type: {
    product: 1
  }

  enum status: {
    proposed: 0,
    approved: 1,
    cancelled: 2,
    test_registration: 3,
    ready: 4,
    suspended: 5,
    closed: 6
  }

  aasm :aasm_payment_category, column: :payment_category, enum: true do
    state :free
    state :paid
  end

  aasm :aasm_event_status, column: :status, enum: true, skip_validation_on_save: false, whiny_transitions: false do
    state :proposed, initial: true
    state :approved
    state :cancelled
    state :test_registration
    state :ready
    state :suspended
    state :closed

    event :proposed do
      transitions from: [:proposed, :approved, :test_registration, :ready, :suspended, :cancelled, :closed], to: :proposed
    end

    event :approved do
      transitions from: :proposed, to: :approved
    end

    event :cancelled do
      transitions from: [:proposed, :approved, :test_registration, :ready, :suspended, :closed], to: :cancelled
    end

    event :test_registration do
      transitions from: [:proposed, :approved], to: :test_registration
    end

    event :ready do
      transitions from: [:proposed, :approved, :test_registration], to: :ready
    end

    event :suspended do
      transitions from: [:proposed, :approved, :test_registration, :ready], to: :suspended
    end

    event :closed do
      transitions from: [:proposed, :approved, :test_registration, :ready, :suspended], to: :closed
    end
  end

  def validate_format_of_registrations_recipients
    if self.registrations_recipients.present?
      emails = self.registrations_recipients.split(',')
      invalid_emails = []
      is_valid = true
      emails.each do |email|
        if email.count("@") != 1
          invalid_emails.push(email)
        elsif email =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
          next
        else
          invalid_emails.push(email)
        end
      end
      if invalid_emails.count > 0
        error_string = invalid_emails.to_sentence + " invalid emails"
        errors.add(:registrations_recipients, error_string.to_s)
        false
      else
        true
      end
    else
      true
    end
  end

  def create_bhandara_details
    return if bhandara_detail.present?
    self.create_bhandara_detail budget: 0, event_id: id
  end

  def get_registration_center_user_id(user_id)
    event_registration_centers = self.registration_centers
    logger.info event_registration_centers.inspect
    registration_center_user = nil
    event_registration_centers.each do |erc|
      logger.info erc.inspect
      registration_center_user = erc.registration_center_users.find{|rcu| rcu.user_id == user_id}
      if registration_center_user.present?
        logger.info "Registration center user found #{registration_center_user.inspect}."
        break
      end
    end
    registration_center_user.try(:id)
  end

  def assign_ds_shop_to_event
    logger.info self.ds_shops
    if !self.ds_shops.nil?
      ds_shop_params = {name: "#{self.event_name} shop", description: self.description, event_id: self.id}
      logger.info ds_shop_params
      self.ds_shops.create(ds_shop_params)
    end
  end

  def event_date
    "#{event_start_date} To #{event_end_date}"
  end

  def event_name_with_location
    "#{event_name}  #{event_location}"
  end

  def assign_master_event_id
    master_event_id = self.id
    self.save
  end

  def self.preloaded_data
    self.includes(includable_date)
  end

  def self.includable_date
    [{ address: [:db_city, :db_state, :db_country] },
     :ds_shops, :payment_gateways,
     {event_seating_category_associations: [:event, :seating_category]},
     {event_awarenesses: [:event_awareness_type]}, :pandal_detail,
     {bhandara_detail: [:bhandara_items]}, :event_cost_estimations,
     {event_team_details: [:sadhak_profile]},
     {event_type: [:digital_assets, :event_type_pricings]},
     {registration_centers: [:users]}, :venue_type, :event_types,
     :prerequisite_events, :seating_categories, {event_tax_type_associations: [:tax_type]}, :handy_attachments, :attachments]
  end

  def proceed_for_bulk_upload(params)

    # Raise error is file or method is missing
    raise SyException.new("File is missing. Please upload a file.") unless (params.has_key?('file') and params[:file].present?)
    raise SyException.new("Please input a valid method.") unless params[:method].present?

    file = params[:file]

    # Raise error if not a valid file type found
    raise SyException, "Please upload a vaild file. Allowed file types [csv, xls, xlsx]" unless [".csv", ".xls", ".xlsx"].include?(File.extname(file.original_filename))

    raise SyException, "File cannot be blank" if file.size == 0

    # Compute file name and file extension for this upload
    params[:original_filename] = "#{File.basename(file.original_filename, File.extname(file.original_filename))}-#{params[:attachable_type]}-#{params[:attachable_id]}"
    params[:file_ext] = File.extname(file.original_filename)

    params[:uploaded_file_name] = "#{File.basename(file.original_filename, File.extname(file.original_filename))}"

    # Attach rails environment prefix
    params[:prefix] = "#{ENV["ENVIRONMENT"]}/#{params[:method]}"

    # Upload the original file to S3
    attachment = Attachment.upload_file(file_name: "#{params[:original_filename]}-original#{params[:file_ext]}", file_path: file.path, content: file, is_secure: true, bucket_name: params[:bucket_name], attachable_id: params[:attachable_id], attachable_type: params[:attachable_type], file_type: file.content_type, prefix: params[:prefix])

    params.delete(:file)

    params[:original_attachment_id] = attachment.id

    self.delay.do_bulk_upload(params)
    # self.do_bulk_upload(params)

    true
  end

  def do_bulk_upload(params)
    begin
      attachment = Attachment.find_by_id(params[:original_attachment_id])

      raise SyException, "Original attachment is missing." unless attachment.present?

      s3_file = Aws::S3::Bucket.new(attachment.s3_bucket).object(attachment.s3_path)

      url = s3_file.presigned_url(:get, secure: true, expires_in: 7200).to_s

      file = open(url)

      # Validate file type and extract data from file
      file_object = validate_file_type(file, attachment.name)

      # Validate headers
      raise SyException.new("Please input valid column headers: [syid, first_name]") unless (file_object[:header].include?("syid") and file_object[:header].include?("first_name"))

      # Check wether there is all blank rows in file
      raise SyException.new("All rows are blank in file. Please input some sadhak profiles for processing.") if file_object[:content].count == 0

      # Find sadhak profiles from database
      valid_invalid_profiles = validate_sadhaks(file_object[:content])

      # Pass current user in parameters
      params[:current_user] = User.find_by_id(params[:current_user_id])

      raise SyException, "You are not authorised to perform this action" unless params[:current_user].present?

      # Call appropiate scrpit for bulk upload
      uploaded_attachments, payment = params[:attachable_type].try(:titleize).constantize.send(params[:method].try(:to_sym), params, valid_invalid_profiles)

    rescue SyException => e
      Rails.logger.info("Manual exception at Event:do_bulk_upload: #{e.message}")
      is_error = true
      message = e.message
    rescue Exception => e
      Rails.logger.info("Runtime Exception at Event:do_bulk_upload: #{e.message}")
      Rails.logger.info(e.backtrace)
      is_error = true
      message = e.message
    end

    begin

      attachments = {}

      ((uploaded_attachments || []) + [attachment]).each do |_attachment|

        s3_file = Aws::S3::Bucket.new(_attachment.s3_bucket).object(_attachment.s3_path)

        url = s3_file.presigned_url(:get, secure: true, expires_in: 7200).to_s

        file = open(url)

        stringIO = StringIO.new()

        stringIO.write file.read

        attachments["#{_attachment.name}"] = stringIO.string

      end

      cc = []
      recipients = [params[:current_user].try(:email), params[:current_user].try(:sadhak_profile).try(:email)]
      cc = ENV['DEVELOPMENT_RESP'].extract_valid_emails if ENV["ENVIRONMENT"] == "development"
      cc = ENV['TESTING_RESP'].extract_valid_emails if ENV["ENVIRONMENT"] == "testing"
      cc = ["shivyogportal@gmail.com"] if ENV["ENVIRONMENT"] == "production"
      from = GetSenderEmail.call(self)

      ApplicationMailer.send_email(from: from, recipients: recipients, cc: cc, subject: "Bulk upload result for #{params[:uploaded_file_name]} - #{DateTime.now.strftime('%F %T')}", template: 'bulk_upload_confirmation', attachments: attachments, is_error: is_error, user: params[:current_user], message: message, payment: payment).deliver

    rescue Exception => e
      Rails.logger.info("Event: do_bulk_upload: Email send error: #{e.message}")
    end
  end

  def validate_sadhaks(profiles)
    # Define local variables
    valid = []
    invalid = []

    # Collect all sadhak profiles
    db_profiles = SadhakProfile.where(syid: profiles.collect{|p| p[:syid].try(:upcase) || p[:SYID].try(:upcase) })

    # Iterate over each profile
    profiles.each_with_index do |sadhak, index|

      # Collect nil values
      nil_values = []
      sadhak.each do |_k, _v|
        nil_values.push(_k) if (_v.nil? or _v == 'NULL' or _v == 'nil')
      end

      # Push to invalid profiles if there are nil values
      if nil_values.count > 0
        sadhak[:reason] = "#{nil_values.to_sentence} columns has invalid values."
        invalid.push(sadhak)
        next
      end

      # Find sadhak in database
      db_sadhak = db_profiles.find{|sp| sp.syid == sadhak[:syid].try(:upcase)}

      # Push to invalid if there is no profile found in database
      unless db_sadhak.present?
        sadhak[:reason] = "No record found with #{sadhak[:syid]} and #{sadhak[:first_name]}."
        invalid.push(sadhak)
        next
      end

      # Match first name
      if db_sadhak.first_name.try(:downcase) != sadhak[:first_name].try(:downcase)
        sadhak[:reason] = "Sadhak profile having #{sadhak[:syid]} does not match first name in database."
        sadhak[:db_first_name] = db_sadhak.first_name
        invalid.push(sadhak)
        next
      end

      # Finally we get valid profile
      sadhak[:sadhak_profile] = db_sadhak
      valid.push(sadhak)

    end

    # Raise error if all sadhak profiles are invalid.
    raise SyException.new("All sadhak profiles are invalid. Please input valid sadhak profiles.") if valid.count == 0

    # Return valid and invalid profiles.
    { valid: valid, invalid: invalid }
  end

  # Method for bulk upload registrations
  def self.event_registration(params, valid_invalid_profiles)

    # Uploaded files attachments
    uploaded_attachments = []

    # Extract and declare variables
    attachment = nil

    # Check current user logged in user
    current_user = params[:current_user]
    raise SyException.new("No logged in user found.") if current_user.try(:id).nil?

    # Find event
    event_id = params[:attachable_id]
    event = self.find_by_id(event_id)
    raise SyException.new("No event found.") if event.nil?

    # Valid excel file header and rows
    success_registration_columns = ['EVENT ID', 'EVENT ORDER ID', 'REGISTRATION REFERENCE NO.', 'REGISTRATION NO.', 'SYID', 'FULL NAME', 'EMAIL', 'MOBILE', 'SEATING_CATEGORY']
    success_registrations = []

    # Invalid file header and rows
    invalid_profile_columns = ['SYID', 'FIRST_NAME', 'ACTUAL_FIRST_NAME','REASON']
    invalid_profiles = []

    # Extract guestemail and registration_center_user_id
    guest_email = current_user.sadhak_profile.email
    registration_center_user_id = event.get_registration_center_user_id(current_user.try(:id))

    # Raise error if there is no category present to event.
    raise SyException.new("No seating category define for #{event.name} event.") if event.seating_categories.count == 0

    # Add seating category columns in header
    success_registration_columns += event.seating_categories.collect{ |sc| sc.try(:category_name).try(:upcase) }

    # Hold event order if there is no error
    @_event_order = nil
    is_success = false

    # Wrap event_order, line_items, event_registrations, valid and invalid file upload
    ApplicationRecord.transaction do

      # Create New event order for all profiles
      event_order = event.event_orders.new(user_id: current_user.try(:id), guest_email: guest_email, registration_center_user_id: registration_center_user_id)
      raise SyException.new(event_order.errors.to_a.first) unless event_order.save

      # Iterate over valid profiles for registration
      valid_invalid_profiles[:valid].each_with_index do |profile, index|

        # Check wether sadhak is already registered for this event.
        if profile[:sadhak_profile].events.include?(event)
          profile[:reason] = "Sadhak profile already registered for this event : #{event.event_name}."
          valid_invalid_profiles[:invalid].push(profile)
          next
        end

        # Find category
        seating_category = event.seating_categories.find{|sc| sc.category_name == profile[:category_name]}

        # No seating category match
        unless seating_category.present?
          profile[:reason] = "Invalid seating category name - #{profile[:category_name]}."
          valid_invalid_profiles[:invalid].push(profile)
          next
        end

        # Find category association
        event_seating_category_association = event.event_seating_category_associations.find_by_seating_category_id(seating_category.try(:id))

        # If there is no category association found
        unless event_seating_category_association.present?
          profile[:reason] = "No seating category association found for category - #{profile[:category_name]}."
          valid_invalid_profiles[:invalid].push(profile)
          next
        end

        # Create event order line item first
        item = event_order.event_order_line_items.new(sadhak_profile_id: profile[:sadhak_profile].try(:id), seating_category_id: seating_category.id, price: event_seating_category_association.price.try(:to_f), event_seating_category_association_id: event_seating_category_association.id)

        # Save the line item
        unless item.save
          profile[:reason] = "There is some error while saving line item- #{item.errors.to_a.first}."
          valid_invalid_profiles[:invalid].push(profile)
          next
        end

        # Create event registration
        event_registration = event_order.event_registrations.new(user_id: event_order.user_id, event_id: event.id, event_seating_category_association_id: item.event_seating_category_association_id, sadhak_profile_id: item.sadhak_profile_id, event_order_line_item_id: item.id)

        # Save event registration
        unless event_registration.save
          profile[:reason] = "Error occured while saving event registration - #{event_registration.errors.to_a.first}."
          valid_invalid_profiles[:invalid].push(profile)
          next
        end

        # Do collect some data
        category_name = event_registration.try(:seating_category).try(:category_name)

        # Create a excel row
        row = []
        row.push(event.id)
        row.push(event_order.id)
        row.push(event_order.reg_ref_number)
        row.push(item.id)
        row.push(profile[:sadhak_profile].try(:syid).present? ? profile[:sadhak_profile].try(:syid) : 'NA')
        row.push(profile[:sadhak_profile].try(:full_name).present? ? profile[:sadhak_profile].try(:full_name) : 'NA')
        row.push(profile[:sadhak_profile].try(:email).present? ? profile[:sadhak_profile].try(:email) : 'NA')
        row.push(profile[:sadhak_profile].try(:mobile).present? ? profile[:sadhak_profile].try(:mobile) : 'NA')
        row.push(category_name.present? ? category_name : 'NA')

        # Logic to push 1 on applied catogry for counting purpose
        category_index = success_registration_columns.index(category_name.try(:upcase))
        row[category_index] = 1 if category_index.present?

        success_registrations.push(row)
      end

      if event_order.event_registrations.count > 0 and success_registrations.count > 0

        # Find gateway
        gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == 'cash'}

        # Create Transaction Log
        transaction_log = TransactionLog.create(transaction_loggable_id: event_order.id, transaction_loggable_type: event_order.class.to_s, other_detail: event_order.other_detail, transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol])

        # Raise error if there is error while creating log
        raise SyException.new(transaction_log.errors.to_a.first) unless transaction_log.errors.empty?

        # Cash payment hash
        payment_hash = {payment_date: Date.today, amount: event_order.total_amount, additional_details: 'Shivyog offline event registration.', is_terms_accepted: true, event_order_id: event_order.id}

        # Do cash payment
        @cash_payment, message = gateway[:controller].constantize.new.create(payment_hash, transaction_log)

        # Raise error if payment unsuccessful
        raise SyException.new(message) if message.present?

        # Update event order
        raise SyException.new(event_order.errors.to_a.first) unless event_order.update_columns(transaction_id: @cash_payment.try(gateway[:transaction_id].to_sym), payment_method: gateway[:payment_method], status: EventOrder.statuses["success"])

        # Generate excel file upload to S3
        attachment = event.generate_and_upload(rows: success_registrations, header: success_registration_columns, data_type: "file", file_name: "#{params[:original_filename]}-valid.xls", params: params)

        # Push attachments to uploaded_attachments
        uploaded_attachments.push(attachment) if attachment.present?

        # Reset value of attachment
        attachment = nil

        @_event_order = event_order
      end

      # Upload Invalid registrations
      if valid_invalid_profiles[:invalid].count > 0
        valid_invalid_profiles[:invalid].each do |profile|
          row = []
          row.push(profile[:syid])
          row.push(profile[:first_name])
          row.push(profile[:db_first_name])
          row.push(profile[:reason])
          invalid_profiles.push(row)
        end

        # Generate excel file upload to S3
        attachment = event.generate_and_upload(rows: invalid_profiles, header: invalid_profile_columns, data_type: "file", file_name: "#{params[:original_filename]}-invalid.xls", params: params)

        # Push attachments to uploaded_attachments
        uploaded_attachments.push(attachment) if attachment.present?
      end

      is_success = true
    end

    @_event_order.reload.notify_joining if is_success && @_event_order.present? && @_event_order.try(:event).try(:notification_service)

    # Return invalid attachment
    return uploaded_attachments, @cash_payment
  end

  def self.event_attendance(params, valid_invalid_profiles)

    # Find event
    event = self.find_by_id(params[:attachable_id])
    raise SyException.new("No event found.") if event.nil?

    # Check current user is peresent?
    current_user = params[:current_user]
    raise SyException.new("No logged in user found.") if current_user.try(:id).nil?

    # Raise error is no valid profiles are present?
    raise SyException.new("Please provide sadhalk profiles.") unless valid_invalid_profiles[:valid].present?

    # Success profiles array
    success_mark_absentee_header = ['SYID', 'FIRST_NAME']
    success_mark_absentee_list = []

    # Invalid profiles array
    invalid_profile_header = ['SYID', 'FIRST_NAME', 'ACTUAL_FIRST_NAME', 'REASON']
    invalid_profiles = []

    # Collect all sadhak profiles and event registrations for this event
    registered_sadhak_ids = event.event_registrations.pluck(:sadhak_profile_id)

    # Absentee list
    absentee_list = []

    # Iterate over valid profiles array
    valid_invalid_profiles[:valid].each do |profile|

      # Set sadhak_profile
      sadhak_profile = profile[:sadhak_profile]

      # Check wether profile is registered for this event or not
      unless registered_sadhak_ids.include?(sadhak_profile.try(:id))
        profile[:reason] = "Sadhak: #{sadhak_profile.try(:full_name)} is not registered for this event: #{event.try(:event_name)}"
        valid_invalid_profiles[:invalid].push(profile)
        next
      end

      # If this profile registered then collect it
      absentee_list.push(sadhak_profile.try(:id))

      # Generate excel row
      row = []
      row.push(profile[:syid])
      row.push(profile[:first_name])
      success_mark_absentee_list.push(row)
    end

    # Generate invalid profile list
    valid_invalid_profiles[:invalid].each do |profile|
      row = []
      row.push(profile[:syid])
      row.push(profile[:first_name])
      row.push(profile[:db_first_name])
      row.push(profile[:reason])
      invalid_profiles.push(row)
    end

    # Attachment that will hold invalid file details
    attachment = nil

    uploaded_attachments = []

    # Create a transaction to update absentee list
    ApplicationRecord.transaction do

      # Mark event registrations as absent
      marked_count = event.event_registrations.where(sadhak_profile_id: absentee_list).update_all(has_attended: false)

      # Raise error if marked count is not equal to absentee count
      raise SyException, "There is some error while updating sadhak attendance." if absentee_list.count != marked_count

      # Upload valid absent list to S3
      attachment = event.generate_and_upload(rows: success_mark_absentee_list, header: success_mark_absentee_header, data_type: "file", file_name: "#{params[:original_filename]}-valid.xls", params: params) if success_mark_absentee_list.count > 0

      # Push attachments to uploaded_attachments
      uploaded_attachments.push(attachment) if attachment.present?

      # Reset value of attachment
      attachment = nil

      # Upload invalid file to S3
      attachment = event.generate_and_upload(rows: invalid_profiles, header: invalid_profile_header, data_type: "file", file_name: "#{params[:original_filename]}-invalid.xls", params: params) if invalid_profiles.count > 0

      # Push attachments to uploaded_attachments
      uploaded_attachments.push(attachment) if attachment.present?

    end

    return uploaded_attachments, nil
  end

  # Method to generate excel file and upload to S3
  def generate_and_upload(options = {})

    # Extract params
    params = options[:params]

    # Upload valid absent list to S3
    file = GenerateExcel.generate(
      rows: options[:rows],
      header: options[:header],
      data_type: options[:data_type]
    )

    # Upload file to s3
    attachment = Attachment.upload_file({file_name: options[:file_name], file_path: file.path, content: file.path, is_secure: true, bucket_name: params[:bucket_name], attachable_id: params[:attachable_id], attachable_type: params[:attachable_type], file_type: "application/vnd.ms-excel", prefix: params[:prefix]})

    # Remove temp file
    begin
      file.close(true)
    rescue Exception => e
      logger.info(e.backtrace)
    end

    attachment
  end

  # To calculate the discount amount
  def calculate_discount(sadhak_profiles)
    discount_amt = 0.0
    seating_associations = EventSeatingCategoryAssociation.where(id: sadhak_profiles.collect{|sp| sp[:event_seating_category_association_id]})
    discount_plan = self.discount_plan
    return 0.0 unless discount_plan.present?
    discount = discount_plan.discount_amount.to_f
    sadhak_profiles.each do |sadhak|
      category = seating_associations.find{|s| s.id == sadhak[:event_seating_category_association_id].to_i}
      raise SyException, "No seating category associated with sadhak profile #{sadhak[:syid]}" unless category.present?
      if discount_plan.try(:discount_type) == "percentage"
        discount_amt += (category.price.to_f * discount) /100
      end
    end
    discount_amt.rnd
  end

  # Method to get cancellation charges per event for given categories
  def cancellation_charges_by_policy(event_order_line_item_ids)
    raise SyException, "Please provide event_order_line_item_ids. method cancellation_charges_by_policy." if event_order_line_item_ids.empty?

    # Compute days difference between event start date and today, i.e used to compute best plan item
    days_diff = (self.event_start_date - Date.today).to_i

    # Return zero cancellation charges as there is no policy attached
    return 0.0 unless self.event_cancellation_plan_id.present?

    # Collect plan items attached to cancellation plan
    plan_items = self.event_cancellation_plan.event_cancellation_plan_items.order(:days_before)

    # Raise error if no plan item found
    return 0.0 unless plan_items.present?

    best_plan_item = plan_items.where("days_before <= ?", days_diff).last

    best_plan_item = plan_items.first unless best_plan_item.present?

    return 0.0 unless best_plan_item.present?

    if best_plan_item.try(:amount_type) == "fixed"
      result = event_order_line_item_ids.count * best_plan_item.amount

    elsif best_plan_item.try(:amount_type) == "percentage"
      result = EventOrderLineItem.where(id: event_order_line_item_ids).includes(:event_seating_category_association).collect{|item| item.try(:event_seating_category_association).try(:price).to_f - item.try(:discount).to_f}.sum * best_plan_item.amount / 100

    else
      result = 9999999
    end

    result.rnd
  end

  def assign_seating_category
    if self.entity_type == 'product'
      category = SeatingCategory.new(category_name: self.entity_type + "_category")
      if category.save
        @event_seating_category_association = EventSeatingCategoryAssociation.create(event_id: self.id, seating_category_id: category.id, price: 50)
      else
        logger.info("Error in creting category")
      end
    end
  end

  # validate discount plan while assigning it to event
  def validate_discount_plan
    if self.discount_plan.present?
      errors.add(:event, "cannot associate this discount plan to current event, as it has the same event in discounted event list") if self.discount_plan.event_ids.include?(self.id)
    end
    errors.empty?
  end

  # To calculate total tax amount,and create a response object
  def calculate_tax_amount(options = {})
    tax_breakup = []
    total_tax = 0.0
    db_payable_amount = options[:original_amount].rnd - options[:total_discount].rnd
    tax_with_order = {total_payable_amount: db_payable_amount, total_tax_applied: 0.0, tax_breakup: [], original_amount: db_payable_amount, total_discount: options[:total_discount].rnd }

    if self.tax_types.present? and self.tax_types.count > 0
      @tax_type_associations = self.event_tax_type_associations

      @total_tax_percentage = @tax_type_associations.pluck(:percent).sum

      # To calculate total tax on discounted payble amount
      #total_tax =  (db_payable_amount * @total_tax_percentage.to_f / 100).rnd

      @tax_type_associations.each do |tax_item|
        tax_per_item = (db_payable_amount * tax_item.percent.to_f / 100)
        tax_breakup.push({tax_name: tax_item.tax_type_name, amount: tax_per_item.rnd})
      end

      total_tax =  tax_breakup.pluck(:amount).sum.rnd

      # Assign values to order object with tax amount
      tax_with_order[:total_payable_amount] = (tax_with_order[:total_payable_amount].rnd + total_tax.rnd)
      tax_with_order[:total_tax_applied] = total_tax.rnd
      tax_with_order[:tax_breakup] = tax_breakup
      tax_with_order[:total_tax_percentage] = @total_tax_percentage.rnd

    end
    tax_with_order
  end

  def get_clp_detail
    info = {
      is_clp_event: false,
      validity_days: 0,
      type: nil
    }
    gps = GlobalPreference.where(key: %w(india_clp_events global_clp_events india_clp_validity global_clp_validity)).all
    india_event_ids = gps.find{|gp| gp.key == 'india_clp_events'}.try(:val).to_s.split(',')
    global_event_ids = gps.find{|gp| gp.key == 'global_clp_events'}.try(:val).to_s.split(',')
    if india_event_ids.include?(self.id.to_s)
      info[:validity_days] = gps.find{|gp| gp.key == 'india_clp_validity'}.try(:val).to_i
      info[:is_clp_event] = true
      info[:type] = 'india'
    elsif global_event_ids.include?(self.id.to_s)
      info[:validity_days] = gps.find{|gp| gp.key == 'global_clp_validity'}.try(:val).to_i
      info[:is_clp_event] = true
      info[:type] = 'global'
    end
    info
  end

  def process_report_generate(params)

    user = User.find(params[:user_id])

    preloaded_events = Event.includes(:discount_plan, :sy_event_company, :event_cancellation_plan, {address: [:db_country, :db_state, :db_city]}, :event_tax_type_associations, :tax_types, :event_seating_category_associations, :seating_categories, {creator_user: [:sadhak_profile]}, :event_type).order(:id)

    if user.super_admin? or user.event_admin?
      events = preloaded_events.where("#{params[:criterion]}".to_sym => params[:from].to_date...params[:to].to_date)
      from = 'support@absclp.com'
    elsif user.india_admin?
      events = preloaded_events.where("#{params[:criterion]}".to_sym => params[:from].to_date...params[:to].to_date).joins(:address).where(addresses: {country_id: 113})
      from = 'registration@shivyogindia.com'
    end

    blob = GenerateExcel.generate GenerateEventsExcel.call(events)

    if params[:recipients].present?
      begin
        ApplicationMailer.send_email(from: from, recipients: params[:recipients], subject: "Event list #{Time.now.strftime('%d%m%Y%H%M%S%N')}.", attachments: Hash["events_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", blob]).deliver
      rescue Exception => e
        Rails.logger.info("Some error ocuured while sending email: Event #process_report_generate, error: #{e.message}")
      end
    end

    return blob unless params[:recipients].present?
  end

  def is_in_india?
    self.try(:address).try(:country_id) == 113
  end

  def india_event?
    self.try(:address).try(:country_id) == 113
  end

  def replicate(options = {})

    begin

      $current_user = User.find(options[:user_id])

      new_events = []

      begin

        ActiveRecord::Base.transaction do

          options[:replicas].to_i.times do

            new_event = amoeba_dup

            new_event.save!

            next unless new_event.persisted?

            # Replicate address manually as there is no support for polymorphic association
            if address.present?

              new_address = address.dup

              new_address.addressable = new_event

              new_address.save!

            end

            # Attachment
            if attachment.present?

              new_attachment = attachment.dup

              new_attachment.attachable = new_event

              new_attachment.save!

            end

            # New handy Attachment
            if handy_attachment.present?

              new_handy_attachment = handy_attachment.dup

              new_handy_attachment.attachable_id = new_event.id

              new_handy_attachment.save!

            end

            # Registration centers - migration

            event_registration_center_associations.each do |rca|

              # Create new event registeration center association

              new_rca = rca.dup

              new_rca.event = new_event

              # Create new registration center

              next unless new_rca.registration_center.present?

              new_rc = new_rca.registration_center.dup

              new_rc.name = "Copy of #{new_rc.name} #{Time.zone.now.strftime('%d%m%Y%H%M%S%6N')}"

              new_rc.save!

              # Assign registration to event registration center assocation

              new_rca.registration_center = new_rc

              new_rca.save!

              # Create registration center users

              rca.registration_center.registration_center_users.each do |rcu|

                new_rcu = rcu.dup

                new_rcu.registration_center = new_rc

                new_rcu.save!

              end

            end

            new_events << new_event if new_event.persisted?

          end

        end

      rescue Exception => e
        message = e.message
      end

      from = GetSenderEmail.call(self)

      ApplicationMailer.send_email(from: from, recipients: options[:recipient], subject: "#{event_name} Replication Result", template: 'event_replicate', events: new_events, sadhak_profile: $current_user.try(:sadhak_profile), message: message).deliver

    rescue => e
      Rollbar.error(e)
    end
  end

  def available_paymeny_gateways

    relation_names = PaymentGatewayType.pluck(:relation_name)

    left_outer_joins = relation_names.collect(&:to_sym) + [:payment_gateway_type]

    selected_attrs_query = relation_names.collect{|relation_name| "#{relation_name}s.alias_name AS #{relation_name}s_alias_name" }.join(", ")

    group_string = relation_names.collect{|relation_name| "#{relation_name}s.alias_name" }.join(', ')

    ActiveSupport::HashWithIndifferentAccess.new(

      PaymentGateway.left_outer_joins(left_outer_joins).where(relation_names.collect{|relation_name| "#{relation_name}s.country_id = :country_id"}.join(" OR "), country_id: address.try(:country_id)).group("payment_gateways.id, payment_gateway_types.name, #{group_string}").where.not(payment_gateways: {id: payment_gateway_ids}).select("payment_gateways.id, UPPER(payment_gateway_types.name) AS payment_gateway_type, #{selected_attrs_query}").collect do |pg|

        pg_compacted = pg.attributes.compact

        key = pg_compacted.keys.find{|k| k.include?('alias_name') }

        pg_compacted[:alias_name] = pg_compacted[key]

        pg_compacted.delete(key)

        pg_compacted

      end.group_by(&:payment_gateway_type)

    )

  end

  def non_selected_payment_gateways

    relation_names = PaymentGatewayType.pluck(:relation_name)

    left_outer_joins = relation_names.collect(&:to_sym) + [:payment_gateway_type]

    where_query = relation_names.collect{|relation_name| "#{relation_name}s.country_id = :country_id"}.join(" OR ")

    PaymentGateway.left_outer_joins(left_outer_joins).where(where_query, country_id: address.try(:country_id), payment_gateway_ids: payment_gateway_ids).where.not(payment_gateways: {id: payment_gateway_ids}).order(:payment_gateway_type_id)

  end

  def by_category_and_mode_of_payment

    data = []

    begin

      event_seating_category_associations.each do |event_seating_category_association|

        payment_info = event_seating_category_association.valid_event_registrations.joins(:event_order).group('event_orders.payment_method').count

        categorized_payments = {}

        TransferredEventOrder.gateways.each do |g|

          if g[:gateway_type] == 'online'

            categorized_payments["Online Payment"] = categorized_payments["Online Payment"].to_i + payment_info[g[:payment_method]].to_i

          else

            categorized_payments[g[:payment_method].titleize] = categorized_payments[g[:payment_method].titleize].to_i + payment_info[g[:payment_method]].to_i

          end

        end

        data << ActiveSupport::HashWithIndifferentAccess.new(categorized_payments.merge({total: categorized_payments.values.map(&:to_i).sum, name: event_seating_category_association.category_name}))

      end

    rescue Exception
    end

    data
  end

  def by_gender

    genders = %w(male female)

    data = vaild_registered_sadhak_profiles.group(:gender).count

    data = genders.collect{ |gender| ActiveSupport::HashWithIndifferentAccess.new ({label: gender, value: data[gender].to_i}) }

    data
  end

  def by_mode_of_payment

    data = []

    begin

      event_orders.joins(:event_registrations).where(event_registrations: {status: EventRegistration.valid_registration_statuses}).group(:payment_method).count.each do |k, v|

        gateway = TransferredEventOrder.gateways.find{|g| g[:payment_method] == k}

        k = 'Others' unless gateway.present?

        found = data.find{|o| o[:name] == k }

        if found.present?

          found[:count] = found[:count].to_i + v.to_i

        else

          data << ActiveSupport::HashWithIndifferentAccess.new({label: k, value: v})

        end

      end

    rescue Exception
    end

    data

  end

  def payment_info_by_rc

    data = []

    begin

      registration_centers.each do |rc|

        event_order_ids = event_orders.joins(:registration_center).where(registration_centers: {id: rc.id}).pluck("event_orders.id")

        txn_hash = transactions_report(event_order_ids)

        mode_wise_data = %w(online cash dd blessed).collect do |mode|

          {
            name: "#{mode} Payment".titleize,
            pending: txn_hash["#{mode}_pending"].to_f,
            approved: txn_hash["#{mode}_approved"].to_f
          }

        end

        data << ActiveSupport::HashWithIndifferentAccess.new({ name: rc.name, approved: mode_wise_data.collect{|o| o[:approved].to_i }.sum.to_f, pending: mode_wise_data.collect{|o| o[:pending].to_i}.sum.to_f })

      end

    rescue Exception
    end

    data

  end

  def by_profession

    data = []

    begin

      data = vaild_registered_sadhak_profiles.joins(:profession).group('professions.name').count

      data = Profession.all.collect{|profession| ActiveSupport::HashWithIndifferentAccess.new({label: profession.name, value: data[profession.name].to_i})  }

    rescue Exception
    end

    data

  end

  def by_country

    valid_event_registrations.joins( {sadhak_profile: [ {address: [:db_country]} ]} ).group("db_countries.name").count.collect{|k, v| ActiveSupport::HashWithIndifferentAccess.new({label: k, value: v}) }

  end

  def by_category

    event_seating_category_associations.collect do |event_seating_category_association|

      ActiveSupport::HashWithIndifferentAccess.new({
        label: event_seating_category_association.category_name,
        value: event_seating_category_association.valid_event_registrations.count
      })

    end

  end

  def by_age_group

    data = []

    begin

      max_age = 100

      start_age = 0

      age_diff = 20

      loop do

        range_year = Date.today.year - start_age - age_diff

        count = vaild_registered_sadhak_profiles.where('extract(year from date_of_birth) < ? AND  extract(year from date_of_birth) >= ?', Date.today.year - start_age, range_year).count

        data << ActiveSupport::HashWithIndifferentAccess.new({ min: start_age + 1, max: start_age + age_diff, label: "#{start_age + 1}-#{start_age + age_diff} yrs", value: count })

        start_age += age_diff

        break if start_age >= max_age

      end

    rescue Exception
    end

    data

  end

  def by_previous_events_registered
    data = []
    data = SadhakProfile.where(id: vaild_registered_sadhak_profiles.pluck(:id)).joins(event_registrations: [:event]).where("event_registrations.status IN (?) AND event_registrations.event_id != ?", EventRegistration.valid_registration_statuses, id).group('sadhak_profiles.id').count(:event_id).group_by{|k, v| v }.collect{|k, v| ActiveSupport::HashWithIndifferentAccess.new({label: "#{k} events", value: v.size}) }
  ensure
    data
  end

  def payment_info

    data = []

    begin

      txn_hash = transactions_report(event_order_ids)

      data = %w(online cash dd blessed).collect do |mode|

        ActiveSupport::HashWithIndifferentAccess.new({
          name: "#{mode} Payment".titleize,
          pending: txn_hash["#{mode}_pending"].to_f,
          approved: txn_hash["#{mode}_approved"].to_f
        })

      end

    rescue Exception
    end

    data

  end

  def transactions_report(event_order_ids)

    transactions_hash = {
      dd_pending: 0.0,
      dd_approved: 0.0,
      online_approved: 0.0,
      cash_approved: 0.0,
      cash_pending: 0.0,
      blessed_approved: 0.0
    }

    if event_order_ids.present?

      TransferredEventOrder.gateways.each do |g|
        transactions_hash[:online_approved] += (Object.const_get g.model).where(event_order_id: event_order_ids, status: g[:success]).sum(:amount) if g.gateway_type == 'online'
      end

      dd_txns = ActiveSupport::HashWithIndifferentAccess.new(PgSyddTransaction.where(event_order_id: event_order_ids).group(:status).sum(:amount))

      cash_txns = ActiveSupport::HashWithIndifferentAccess.new(PgCashPaymentTransaction.where(event_order_id: event_order_ids).group(:status).sum(:amount))

      transactions_hash[:online_approved] = transactions_hash[:online_approved].to_f

      transactions_hash[:dd_pending] = dd_txns[:pending].to_f

      transactions_hash[:dd_approved] = dd_txns[:approved].to_f

      transactions_hash[:cash_pending] = cash_txns[:pending].to_f

      transactions_hash[:cash_approved] = cash_txns[:approved].to_f

      transactions_hash[:blessed_approved] = EventOrder.where(id: event_order_ids, payment_method: 'Blessed').sum("total_amount - total_discount").to_f

    end

    ActiveSupport::HashWithIndifferentAccess.new(transactions_hash)
  end

  def self.clp_event_ids
    (GlobalPreference.get_value_of('india_clp_events').to_s.split(',') + GlobalPreference.get_value_of('global_clp_events').to_s.split(',')).map { |id| id.to_i }
  end

  def is_ashram_residential_shivir?
    event_type.try(:name) == ASHRAM_RESIDENTIAL_SHIVIR
  end

  def currency_code
    pay_in_usd? ? 'USD' : country_currency_code
  end

  def generate_event_slug
    "#{SecureRandom.uuid}-#{SecureRandom.hex(3)}"
  end

  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end

  def create_event_order(event_order_params)
    if event_order_params[:event_order_line_items_attributes].blank?
      raise SyException, 'Please input some sadhak profiles for registrations'
    end

    event_order_params[:sadhak_profiles] = event_order_params[:event_order_line_items_attributes].values

    # Method call to validate forum details and profile details if sy club id present
    err_message = event_order_params[:sy_club_id].present? ? EventOrder.validate_forum_details(event_order_params) : ''
    raise SyException, err_message if err_message.present?

    # check if event found and status of event allows registrations
    is_event_running = (end_date_ignored? || (event_end_date.present? && Date.today <= event_end_date))
    is_admin = (event_order_params[:current_user].present? and (event_order_params[:current_user].super_admin? or event_order_params[:current_user].event_admin? or event_order_params[:current_user].india_admin?))
    is_rc = event_order_params[:current_user].try(:rc?, self)

    raise SyException, 'Event is closed. Please contact Ashram.' unless is_event_running || is_admin || is_rc

    raise SyException, 'Event is not ready for Registrations. Please contact Ashram.' unless status == 'test_registration' || status == 'ready' || is_admin || is_rc

    Rails.logger.info("Guest Email Before: #{event_order_params[:guest_email]}")

    # Assign dummy email if not a valid guest email found
    guest_email = if event_order_params[:guest_email].present? then
                    event_order_params[:guest_email]
                  else
                    event_order_params[:current_user].try(:sadhak_profile).try(:email).present? ? event_order_params[:current_user].sadhak_profile.email : 'syitemails@gmail.com'
                  end

    raise SyException, 'Email address received for registration confirmation cannot be empty/invalid.' unless guest_email.present? && guest_email.is_valid_email?

    valid_profiles_to_register = []
    seating_categories_requested = []

    event_order_params['sadhak_profiles'].each_with_index do |sp, i|
      sadhak_profile = SadhakProfile.find(sp[:sadhak_profile_id])

      raise SyException, 'Sadhak Profile not found.' unless sadhak_profile.present?
      raise SyException, "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid} is not allowed to register on event." if sadhak_profile.banned?
      raise SyException, "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid} already registered for this event." unless !sadhak_profile.events.include?(self) or (event_order_params[:sy_club_id].present? and (sadhak_profile.renewal_events || []).include?(self))
      raise "Sadhak is not eligible to register this event. Sadhak must be #{event.min_age_criteria.to_i} years old." unless sadhak_profile.has_age_eligibility_to_register_on?(self) if is_in_india? && min_age_criteria.to_i > 0

      if sadhak_profile.check_prerequisite_criterion?(self)
        sp[:id] = sadhak_profile.id
        sp[:first_name] = sadhak_profile.first_name
        sp[:is_extra_seat] = sp[:is_extra_seat] ? sp[:is_extra_seat] : false
        sp[:available_for_seva] = sp[:available_for_seva] if sp[:available_for_seva].present? and sp[:available_for_seva] == 'true' and has_seva_preference?

        scr = seating_categories_requested.find {|sc| sc[:id] == sp['event_seating_category_association_id'] }

        if scr.nil?
          seating_categories_requested.push({
            id: sp['event_seating_category_association_id'],
            seats_requested: 1,
            sadhaks: [sadhak_profile.id]
          })
        else
          scr[:seats_requested] += 1
          scr[:sadhaks].push(sadhak_profile.id)
        end

        valid_profiles_to_register.push(sp)
      else
        prerequisite_events_string = (prerequisite_events + Event.where(event_type_id: event_prerequisites_event_types.pluck(:event_type_id))).collect{|e| e.event_name_with_location}.join(' | ')
        raise SyException, prerequisite_message.present? ? prerequisite_message : "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid} does not meet prerequisite criterion. In order to register for #{event_name}, it is mandatory that you have attended #{prerequisite_events_string}."
      end
    end

    #all sadhak profiles are valid to be added to event order line items
    seating_categories_requested.each do |scr|

      event_seating_category_association_model = EventSeatingCategoryAssociation.find(scr[:id])

      #check if EventSeatingCategoryAssociation belongs to the requested event
      raise SyException, "Seating category (#{event_seating_category_association_model.category_name}) does not belong to requested event." unless event_seating_category_association_model.event == self

      #check if number of seats requested are available in this category
      seats_occupied = event_registrations.where(:event_seating_category_association_id  => scr[:id], :status => EventOrderLineItem.valid_line_item_statuses).count
      total_seats = event_seating_category_association_model.seating_capacity
      seats_available = total_seats - seats_occupied

      if event_order_params[:current_user].present? and (event_order_params[:current_user].super_admin? or event_order_params[:current_user].event_admin?)
        seats_available < scr[:seats_requested] and scr[:sadhaks].each do |sadhak_id|
          sp = valid_profiles_to_register.find {|s| s[:id] == sadhak_id }
          sp[:is_extra_seat] = seats_available < 1
          seats_available -= 1
        end
      else
        #check if requested number of seats are available
        if seats_available < scr[:seats_requested]
          if seats_available <= 0
            raise SyException, "No seats available in #{event_seating_category_association_model.seating_category.category_name} category."
          else
            raise SyException, "Only #{seats_available} seats are available in #{event_seating_category_association_model.seating_category.category_name} category"
          end
        end
      end
    end

    # all good, we can continue with the order create
    # valid_profiles_to_register
    event_order_hash = {
      event_id: id,
      user_id: event_order_params[:current_user].try(:id),
      guest_email: guest_email,
      sy_club_id: event_order_params[:sy_club_id],
      is_guest_user: event_order_params[:current_user].blank?
    }

    event_order = EventOrder.new(event_order_hash)

    if is_rc
      event_order.registration_center_user_id = get_registration_center_user_id(event_order_params[:current_user].try(:id))
    end

    if is_ashram_residential_shivir?

      event_order_params[:sadhak_profiles].each do |sadhak_profile|
        @special_event_sadhak_profile_other_info = SpecialEventSadhakProfileOtherInfo.where(sadhak_profile_id: sadhak_profile[:sadhak_profile_id], event_id: try(:id), event_order_line_item_id: nil).order('created_at DESC').first

        raise "SY#{sadhak_profile[:sadhak_profile_id]} other informations not found." unless @special_event_sadhak_profile_other_info.present?

        raise @special_event_sadhak_profile_other_info.errors.full_messages.first unless @special_event_sadhak_profile_other_info.update(event_order_params.slice(:signature, :accepted_terms_and_conditions))

      end

    end

    raise SyException, event_order.errors.full_messages.first unless event_order.save

    valid_profiles_to_register.each do |vp|
      event_seating_category_association_model = EventSeatingCategoryAssociation.find(vp[:event_seating_category_association_id ])
      event_order_line_item_hash = {
        sadhak_profile_id: vp[:id],
        event_seating_category_association_id: event_seating_category_association_model.id,
        price: event_seating_category_association_model.price,
        seating_category_id: event_seating_category_association_model.seating_category.id,
        is_extra_seat: vp[:is_extra_seat],
        available_for_seva: vp[:available_for_seva]
      }
      line_item = event_order.event_order_line_items.create(event_order_line_item_hash)
      raise SyException, line_item.errors.full_messages.first unless line_item.errors.empty?
    end

    event_order
  end

  def cancel_all_registrations(user_id)

    begin

      current_user = User.find_by_id(user_id)

      header = %w(EVENT_ORDER_ID REG_REF_NUMBER TRANSACTION_ID PAID_AMOUNT PAYMENT_METHOD REGISTERD_SADHAK_SYIDS REFUNDED_AMOUNT PARTIAL CANCELLATION_CHARGES AUTOMATIC_REFUND PAYMENT_REFUND_ID EVENT_ORDER_LINE_ITEM_IDS EVENT_REGISTRATION_IDS MESSAGE)

      rows = []

      event_orders.where(id: valid_event_registrations.pluck(:event_order_id)).find_each(batch_size: 1) do |event_order|

        row = []

        begin

          next if event_order.valid_event_registrations.count.zero?

          db_paid_amount = 0
          cancellation_charges_by_policy = 0
          sadhak_profiles = []
          db_refunded_amount = 0
          partial_refund = nil
          event_registration_ids = event_order.valid_event_registrations.pluck(:id).join(';')
          message = nil

          sadhak_profiles = event_order.valid_event_registrations.collect{|r| {syid: r.sadhak_profile_id.to_s, firstName: r.sadhak_profile.first_name, event_seating_category_association_id: r.event_seating_category_association_id.to_s, event_order_line_item_id: r.event_order_line_item_id.to_s} }

          # Create refund params
          request_params = {
            event_id: event_order.event_id,
            event_order_id: event_order.id,
            method: event_order.payment_method,
            transaction_id: event_order.transaction_id,
            reg_ref_number: event_order.reg_ref_number,
            sadhak_profiles: sadhak_profiles,
            is_tranfer: false
          }

          @event_order = event_order

          @event = event_order.event

          # Assign TransferredEventOrder model to variable
          @t = TransferredEventOrder

          @event_order_policy = EventOrderPolicy.new(current_user, @event_order)

          @from_event_order = EventOrder.includes(:event).find_by_reg_ref_number(request_params[:reg_ref_number])
          raise SyException, "Event order is not found with reg_ref_number: #{request_params[:reg_ref_number]}." unless @from_event_order.present?

          # Event has been closed. Allowed to super admin and event admin anytime
          # raise SyException, "Event registration has been closed. Please contact event organiser for cancellation/downgrade/transfer." unless (@event.event_start_date.present? and DateTime.now <= (@event.event_start_date - 2) || @event_order_policy.payment_refunds?)

          # Block payment refund for particular 1k type shivir(s)
          raise 'Refund is not allowed for 1k type shivir(s).' unless @event_order_policy.can_refund_1k_shivir?

          # Check for ui amount
          # ui_amount = request_params[:amount].to_f.round(2)
          # raise SyException, "Please input valid amount." if [nil, "", "NULL", "nil"].include?(ui_amount)

          # Compute is_downgraded, details, is_tranfer and refundable amount
          downgraded = @event_order.compute_info(request_params)

          # Compute wether it is transfer case or not
          is_transfer = downgraded[:is_transfer]

          # Declare some variable if transfer case
          if is_transfer
            if @event.automatic_refund?
              @to_event = @event_order.event
            else
              # Set shifted event
              @to_event = Event.find_by_id(params[:shifted_event_id])
            end
            raise SyException, "Transferred event not found." unless @to_event.present?

            # Check and set parameter is_transfer
            raise SyException, "This is transfer case but UI parameters is not matching." if request_params[:is_transfer] != is_transfer
            request_params[:is_transfer] = is_transfer
          end

          # To block cancellation/upgrade/downgrade of registration if event is global or india clp events.
          clp_event_ids = (GlobalPreference.get_value_of('india_clp_events').to_s.split(',') + GlobalPreference.get_value_of('global_clp_events').to_s.split(',')).map { |id| id.to_i }

          # Assign API calculated refundable amount
          db_refundable_amount = downgraded[:amount]

          # Cancellation charges using cancellation policy
          cancellation_charges_by_policy = @event.cancellation_charges_by_policy(sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]})

          # Authorize request if not an automatic refund

          # raise 'You need to sign in or sign up before continuing.' unless current_user.present? unless @event.automatic_refund?

          if is_transfer or downgraded[:is_downgraded] or db_refundable_amount == 0
            cancellation_charges_by_policy = 0.0
          end

          # Compute api side transactions and total paid amount and refundable amount
          txn_details = @t.get_txn_details(@event_order.id)
          db_paid_amount = txn_details.collect{|t| t[:total_paid_amount]}.sum.to_f.round(2)

          # Raise error if any error while getting transaction details
          raise SyException, @t.get_refund_errors.first unless @t.get_refund_errors.empty?

          # Collect all payment methods for event order by which payment is made
          event_order_payment_methods = (txn_details || []).collect{|t| t[:payment_method]}

          # Raise error if payment methods include Ccavenue payment and automatic refund is true
          raise SyException, 'You are not allowed to make direct refund as it is not supported by payment gateway. Need help, Please contact shivir organisers.' if @event.automatic_refund? and (event_order_payment_methods.include?('Ccavenue Payment') or event_order_payment_methods.include?('Payfast Payment') or event_order_payment_methods.include?('Hdfc Payment'))

          ui_amount = db_refundable_amount - cancellation_charges_by_policy

          request_params[:amount] = ui_amount

          raise SyException, "You cannot make refund because available amount #{db_paid_amount} is lesser than requested amount #{ui_amount}, cancellation charges: #{cancellation_charges_by_policy}." if db_paid_amount < (ui_amount + cancellation_charges_by_policy)

          raise SyException, "You cannot make refund because requested amount doesn't match." unless db_refundable_amount == ui_amount + cancellation_charges_by_policy

          # Action
          action = if is_transfer and downgraded[:is_downgraded] then
                      PaymentRefund.actions['transfer_downgrade']
                    else
                      if downgraded[:is_downgraded] then
                        PaymentRefund.actions['downgrade']
                      else
                        if is_transfer then
                          PaymentRefund.actions['transfer']
                        else
                          db_refundable_amount == 0 ? PaymentRefund.actions['update_record'] : PaymentRefund.actions['cancellation']
                        end
                      end
                    end
          if (clp_event_ids.include?(@event.id) or clp_event_ids.include?(@to_event.try(:id)))
            raise SyException, 'Category, Shivir and Name Change action(s) are not allowed on CLP.' if PaymentRefund.actions['cancellation'] != action
            # Authorize request. Allowed: Superadmin, event admin and india admin
            raise 'You are not authorized to perform this action.' unless @event_order_policy.clp_refund?
            raise 'Renewed/Expired membership(s) are not allowed to refund.' if (request_params[:details].collect{|d| d[:old_item_status]} & EventRegistration.statuses.slice(:expired, :renewed, :cancelled, :transferred, :cancelled_refunded, :shivir_changed).keys).size > 0
          end

          # Perform check that sadhak already joined to this event
          db_sadhaks = SadhakProfile.includes(:events).where(id: sadhak_profiles.collect{|sp| sp[:syid]})

          # Iterate over each sadhak profile
          request_params[:details].each do |sp|
            sadhak = db_sadhaks.find{|s| s.id == sp[:syid].to_i}

            raise SyException, "Sadhak Profile with SYID: #{sp[:syid]} does not found in database." unless sadhak.present?

            if is_transfer and not @event.automatic_refund?
              # If sadhak changing shivir and manual mode of refund
              raise SyException, "SYID: #{sadhak.try(:syid)} Name: #{sadhak.try(:full_name)} is already registered to event: #{@to_event.try(:event_name)}." if sadhak.event_ids.include?(@to_event.id)
            else
              raise SyException, "SYID: #{sadhak.try(:syid)} Name: #{sadhak.try(:full_name)} is already registered to event: #{@event.try(:event_name)}." if (sp[:touched_columns] || []).include?("sadhak_profile_id") and sadhak.event_ids.include?(@event.id)
            end

            if (is_transfer and not @event.automatic_refund?) or (sp[:touched_columns] || []).include?("sadhak_profile_id")
              # To check wether sadhak profile is banned or not
              raise SyException, "SYID: #{sadhak.try(:syid)} Name: #{sadhak.try(:full_name)} is banned." if sadhak.banned?
            end
          end

          # Create cancellation/upgrade/transfer request for each profile
          ActiveRecord::Base.transaction do

            raise SyException, "Not a valid action." unless PaymentRefund.actions.values.include?(action)

            # Create payment refund request
            @payment_refund = PaymentRefund.new(event_order_id: @from_event_order.id, event_id: @event.id, action: action, request_object: request_params, max_refundable_amount: db_refundable_amount, event_cancellation_plan_id: @event.event_cancellation_plan_id, cancellation_charges: cancellation_charges_by_policy, policy_refundable_amount: (db_refundable_amount - cancellation_charges_by_policy), shifted_event_order_id: (is_transfer and @event.automatic_refund?) ? @event_order.id : nil)

            raise SyException, @payment_refund.errors.full_messages.first unless @payment_refund.save

            # Iterate over each sadhak profile details to create request
            request_params[:details].each do |sp|

              # If it is transfer case then assign transferred to event id to payment line items
              if [PaymentRefund.actions["transfer_downgrade"], PaymentRefund.actions["transfer"]].include?(action)
                event_id = @to_event.id
              end

              # Create payment refund request
              payment_refund_line_item = PaymentRefundLineItem.new(sadhak_profile_id: sp[:syid], event_id: event_id, event_registration_id: sp[:event_registration_id], event_seating_category_association_id: sp[:event_seating_category_association_id], payment_refund_id: @payment_refund.id, event_order_line_item_id: sp[:event_order_line_item_id], old_item_status: sp[:old_item_status])

              raise SyException, payment_refund_line_item.errors.full_messages.first unless payment_refund_line_item.save
            end

            # Update intermediate status
            @payment_refund.update_intermediate_line_item_status

            raise SyException, @payment_refund.errors.full_messages.first unless @payment_refund.errors.empty?
          end

          # Success parameters
          message = "Your request has been initiated. Please use your registration reference number-#{@event_order.try(:reg_ref_number)} to track request status."
          refunds = nil
          db_refunded_amount = 0.0
          partial_refund = nil
          refund_other_details = request_params.except(:details).clone

          # If automatic refund is true means do instant refund else place request, intentionally refund the amount if automatic_refund check is false.
          if @event.automatic_refund? || true
            begin
              if ui_amount > 0.0
                # Set refund other details that is needed in transaction log
                refund_other_details[:is_downgraded] = downgraded[:is_downgraded]
                refund_other_details[:db_refundable_amount] = db_refundable_amount
                refund_other_details[:action] = PaymentRefund.actions.key(action)

                # Process refund
                refund_details = @t.process_refund(txn_details, ui_amount, refund_other_details)
                db_refunded_amount = refund_details[:db_refunded_amount]
                refunds = refund_details[:refunds]

                if db_refunded_amount > 0.0
                  if db_refunded_amount == ui_amount
                    message = "We have successfully processed your refund. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding refunds.' : ''}"
                    partial_refund = false
                  else
                    message = "Due to some internal error, We could not processed full refund. Sorry for the inconvenience happend to you. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding partial refund.' : ''} For remaining refund, Please contact to the Ashram."
                    partial_refund = true
                  end

                  # Update request object and attach what has been refunded.
                  refund_other_details[:total_refunded_amount] = db_refunded_amount
                  refund_other_details[:refunds] = refunds
                  refund_other_details[:partial_refund] = partial_refund

                  # Update request object with errors
                  refund_other_details[:errors] = @payment_refund.errors.full_messages

                elsif @t.get_refund_errors.count > 0
                  raise SyException, @t.get_refund_errors.first
                else
                  raise SyException, 'Something went wrong while processing your refund.'
                end
              end

              # Clear all errors as request completed
              @payment_refund.errors.clear

              # Update refunded amount and status and push errors to db if any while updation
              @payment_refund.update(amount_refunded: db_refunded_amount, status: @payment_refund.class.statuses["refunded"], request_object: refund_other_details.deep_merge(request_params))

              # Update registrations and line items
              @payment_refund.perform_updation

              message = "We have successfully processed your request. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding your request.' : ''}"

              # Send refund email
              @payment_refund.reload.refund_email({refunds: refunds, total_refunded_amount: db_refunded_amount, partial_refund: partial_refund}) if @payment_refund.event.try(:notification_service)

              # Request is completed send refund sms
              db_sadhaks.each do |sadhak_profile|

                sadhak_profile.delay.send_sms_to_sadhak("NMS #{sadhak_profile.syid}-#{sadhak_profile.full_name}\nWe have successfully processed your refund for #{event_name_with_location}.")

              end if @payment_refund.event.try(:notification_service)

            rescue SyException => e
              # Delete captured payment refund requeste to allow user to place request again and restore line items updated status
              @payment_refund.update_intermediate_line_item_status(true)

              @payment_refund.update(is_deleted: true)

              Rails.logger.info("EventOrdersController, payment_refunds: errors while restroing line items and event registrations statuses: #{@payment_refund.errors.full_messages}") unless @payment_refund.errors.empty?

              raise SyException, e.message

            rescue Exception => e
              # Delete captured payment refund requeste to allow user to place request again and restore line items updated status
              @payment_refund.update_intermediate_line_item_status(true)

              @payment_refund.update(is_deleted: true)

              Rails.logger.info("EventOrdersController, payment_refunds: errors while restroing line items and event registrations statuses: #{@payment_refund.errors.full_messages}") unless @payment_refund.errors.empty?

              raise Exception, e.message
            end
          end

        rescue Exception => e
          message = e.message
        end

        row << event_order.id
        row << event_order.reg_ref_number
        row << event_order.transaction_id
        row << db_paid_amount.to_f.round(2)
        row << event_order.payment_method
        row << sadhak_profiles.collect{|sp| "SY#{sp[:syid]}"}.join(';')
        row << db_refunded_amount.to_f.round(2)
        row << partial_refund
        row << cancellation_charges_by_policy.to_f.round(2)
        row << @event.try(:automatic_refund?)
        row << @payment_refund.try(:id)
        row << sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]}.join(';')
        row << event_registration_ids
        row << message

        rows << row

      end

      begin
        from = GetSenderEmail.call(@event)
        recipients = [current_user.sadhak_profile.try(:email), current_user.email].extract_valid_emails.uniq
        ApplicationMailer.send_email(
          from: from,
          recipients: recipients,
          subject: "Event #{event_name_with_location} Refund Status.",
          attachments: {"event-#{id}-#{event_name.parameterize}-refund-report.xls" => GenerateExcel.generate(rows: rows, header: header)}).deliver if rows.size > 0 && recipients.size > 0
      rescue => e
        Rollbar.error(e)
      end

    rescue => e
      Rollbar.error(e)
    end
    errors.empty?
  end

  def cancel_registration_by_event_order_id(user_id, event_order_id)

    begin

      current_user = User.find_by_id(user_id)

      header = %w(EVENT_ORDER_ID REG_REF_NUMBER TRANSACTION_ID PAID_AMOUNT PAYMENT_METHOD REGISTERD_SADHAK_SYIDS REFUNDED_AMOUNT PARTIAL CANCELLATION_CHARGES AUTOMATIC_REFUND PAYMENT_REFUND_ID EVENT_ORDER_LINE_ITEM_IDS EVENT_REGISTRATION_IDS MESSAGE)

      rows = []

      event_orders.where(id: event_order_id).find_each(batch_size: 1) do |event_order|

        row = []

        begin

          next if event_order.valid_event_registrations.count.zero?

          db_paid_amount = 0
          cancellation_charges_by_policy = 0
          sadhak_profiles = []
          db_refunded_amount = 0
          partial_refund = nil
          event_registration_ids = event_order.valid_event_registrations.pluck(:id).join(';')
          message = nil

          sadhak_profiles = event_order.valid_event_registrations.collect{|r| {syid: r.sadhak_profile_id.to_s, firstName: r.sadhak_profile.first_name, event_seating_category_association_id: r.event_seating_category_association_id.to_s, event_order_line_item_id: r.event_order_line_item_id.to_s} }

          # Create refund params
          request_params = {
            event_id: event_order.event_id,
            event_order_id: event_order.id,
            method: event_order.payment_method,
            transaction_id: event_order.transaction_id,
            reg_ref_number: event_order.reg_ref_number,
            sadhak_profiles: sadhak_profiles,
            is_tranfer: false
          }

          @event_order = event_order

          @event = event_order.event

          # Assign TransferredEventOrder model to variable
          @t = TransferredEventOrder

          @event_order_policy = EventOrderPolicy.new(current_user, @event_order)

          @from_event_order = EventOrder.includes(:event).find_by_reg_ref_number(request_params[:reg_ref_number])
          raise SyException, "Event order is not found with reg_ref_number: #{request_params[:reg_ref_number]}." unless @from_event_order.present?

          # Event has been closed. Allowed to super admin and event admin anytime
          # raise SyException, "Event registration has been closed. Please contact event organiser for cancellation/downgrade/transfer." unless (@event.event_start_date.present? and DateTime.now <= (@event.event_start_date - 2) || @event_order_policy.payment_refunds?)

          # Block payment refund for particular 1k type shivir(s)
          raise 'Refund is not allowed for 1k type shivir(s).' unless @event_order_policy.can_refund_1k_shivir?

          # Check for ui amount
          # ui_amount = request_params[:amount].to_f.round(2)
          # raise SyException, "Please input valid amount." if [nil, "", "NULL", "nil"].include?(ui_amount)

          # Compute is_downgraded, details, is_tranfer and refundable amount
          downgraded = @event_order.compute_info(request_params)

          # Compute wether it is transfer case or not
          is_transfer = downgraded[:is_transfer]

          # Declare some variable if transfer case
          if is_transfer
            if @event.automatic_refund?
              @to_event = @event_order.event
            else
              # Set shifted event
              @to_event = Event.find_by_id(params[:shifted_event_id])
            end
            raise SyException, "Transferred event not found." unless @to_event.present?

            # Check and set parameter is_transfer
            raise SyException, "This is transfer case but UI parameters is not matching." if request_params[:is_transfer] != is_transfer
            request_params[:is_transfer] = is_transfer
          end

          # To block cancellation/upgrade/downgrade of registration if event is global or india clp events.
          clp_event_ids = (GlobalPreference.get_value_of('india_clp_events').to_s.split(',') + GlobalPreference.get_value_of('global_clp_events').to_s.split(',')).map { |id| id.to_i }

          # Assign API calculated refundable amount
          db_refundable_amount = downgraded[:amount]

          # Cancellation charges using cancellation policy
          cancellation_charges_by_policy = @event.cancellation_charges_by_policy(sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]})

          # Authorize request if not an automatic refund

          # raise 'You need to sign in or sign up before continuing.' unless current_user.present? unless @event.automatic_refund?

          if is_transfer or downgraded[:is_downgraded] or db_refundable_amount == 0
            cancellation_charges_by_policy = 0.0
          end

          # Compute api side transactions and total paid amount and refundable amount
          txn_details = @t.get_txn_details(@event_order.id)
          db_paid_amount = txn_details.collect{|t| t[:total_paid_amount]}.sum.to_f.round(2)

          # Raise error if any error while getting transaction details
          raise SyException, @t.get_refund_errors.first unless @t.get_refund_errors.empty?

          # Collect all payment methods for event order by which payment is made
          event_order_payment_methods = (txn_details || []).collect{|t| t[:payment_method]}

          # Raise error if payment methods include Ccavenue payment and automatic refund is true
          raise SyException, 'You are not allowed to make direct refund as it is not supported by payment gateway. Need help, Please contact shivir organisers.' if @event.automatic_refund? and (event_order_payment_methods.include?('Ccavenue Payment') or event_order_payment_methods.include?('Payfast Payment') or event_order_payment_methods.include?('Hdfc Payment'))

          ui_amount = db_refundable_amount - cancellation_charges_by_policy

          request_params[:amount] = ui_amount

          raise SyException, "You cannot make refund because available amount #{db_paid_amount} is lesser than requested amount #{ui_amount}, cancellation charges: #{cancellation_charges_by_policy}." if db_paid_amount < (ui_amount + cancellation_charges_by_policy)

          raise SyException, "You cannot make refund because requested amount doesn't match." unless db_refundable_amount == ui_amount + cancellation_charges_by_policy

          # Action
          action = if is_transfer and downgraded[:is_downgraded] then
                      PaymentRefund.actions['transfer_downgrade']
                    else
                      if downgraded[:is_downgraded] then
                        PaymentRefund.actions['downgrade']
                      else
                        if is_transfer then
                          PaymentRefund.actions['transfer']
                        else
                          db_refundable_amount == 0 ? PaymentRefund.actions['update_record'] : PaymentRefund.actions['cancellation']
                        end
                      end
                    end
          if (clp_event_ids.include?(@event.id) or clp_event_ids.include?(@to_event.try(:id)))
            raise SyException, 'Category, Shivir and Name Change action(s) are not allowed on CLP.' if PaymentRefund.actions['cancellation'] != action
            # Authorize request. Allowed: Superadmin, event admin and india admin
            raise 'You are not authorized to perform this action.' unless @event_order_policy.clp_refund?
            raise 'Renewed/Expired membership(s) are not allowed to refund.' if (request_params[:details].collect{|d| d[:old_item_status]} & EventRegistration.statuses.slice(:expired, :renewed, :cancelled, :transferred, :cancelled_refunded, :shivir_changed).keys).size > 0
          end

          # Perform check that sadhak already joined to this event
          db_sadhaks = SadhakProfile.includes(:events).where(id: sadhak_profiles.collect{|sp| sp[:syid]})

          # Iterate over each sadhak profile
          request_params[:details].each do |sp|
            sadhak = db_sadhaks.find{|s| s.id == sp[:syid].to_i}

            raise SyException, "Sadhak Profile with SYID: #{sp[:syid]} does not found in database." unless sadhak.present?

            if is_transfer and not @event.automatic_refund?
              # If sadhak changing shivir and manual mode of refund
              raise SyException, "SYID: #{sadhak.try(:syid)} Name: #{sadhak.try(:full_name)} is already registered to event: #{@to_event.try(:event_name)}." if sadhak.event_ids.include?(@to_event.id)
            else
              raise SyException, "SYID: #{sadhak.try(:syid)} Name: #{sadhak.try(:full_name)} is already registered to event: #{@event.try(:event_name)}." if (sp[:touched_columns] || []).include?("sadhak_profile_id") and sadhak.event_ids.include?(@event.id)
            end

            if (is_transfer and not @event.automatic_refund?) or (sp[:touched_columns] || []).include?("sadhak_profile_id")
              # To check wether sadhak profile is banned or not
              raise SyException, "SYID: #{sadhak.try(:syid)} Name: #{sadhak.try(:full_name)} is banned." if sadhak.banned?
            end
          end

          # Create cancellation/upgrade/transfer request for each profile
          ActiveRecord::Base.transaction do

            raise SyException, "Not a valid action." unless PaymentRefund.actions.values.include?(action)

            # Create payment refund request
            @payment_refund = PaymentRefund.new(event_order_id: @from_event_order.id, event_id: @event.id, action: action, request_object: request_params, max_refundable_amount: db_refundable_amount, event_cancellation_plan_id: @event.event_cancellation_plan_id, cancellation_charges: cancellation_charges_by_policy, policy_refundable_amount: (db_refundable_amount - cancellation_charges_by_policy), shifted_event_order_id: (is_transfer and @event.automatic_refund?) ? @event_order.id : nil)

            raise SyException, @payment_refund.errors.full_messages.first unless @payment_refund.save

            # Iterate over each sadhak profile details to create request
            request_params[:details].each do |sp|

              # If it is transfer case then assign transferred to event id to payment line items
              if [PaymentRefund.actions["transfer_downgrade"], PaymentRefund.actions["transfer"]].include?(action)
                event_id = @to_event.id
              end

              # Create payment refund request
              payment_refund_line_item = PaymentRefundLineItem.new(sadhak_profile_id: sp[:syid], event_id: event_id, event_registration_id: sp[:event_registration_id], event_seating_category_association_id: sp[:event_seating_category_association_id], payment_refund_id: @payment_refund.id, event_order_line_item_id: sp[:event_order_line_item_id], old_item_status: sp[:old_item_status])

              raise SyException, payment_refund_line_item.errors.full_messages.first unless payment_refund_line_item.save
            end

            # Update intermediate status
            @payment_refund.update_intermediate_line_item_status

            raise SyException, @payment_refund.errors.full_messages.first unless @payment_refund.errors.empty?
          end

          # Success parameters
          message = "Your request has been initiated. Please use your registration reference number-#{@event_order.try(:reg_ref_number)} to track request status."
          refunds = nil
          db_refunded_amount = 0.0
          partial_refund = nil
          refund_other_details = request_params.except(:details).clone

          # If automatic refund is true means do instant refund else place request, intentionally refund the amount if automatic_refund check is false.
          if @event.automatic_refund? || true
            begin
              if ui_amount > 0.0
                # Set refund other details that is needed in transaction log
                refund_other_details[:is_downgraded] = downgraded[:is_downgraded]
                refund_other_details[:db_refundable_amount] = db_refundable_amount
                refund_other_details[:action] = PaymentRefund.actions.key(action)

                # Process refund
                refund_details = @t.process_refund(txn_details, ui_amount, refund_other_details)
                db_refunded_amount = refund_details[:db_refunded_amount]
                refunds = refund_details[:refunds]

                if db_refunded_amount > 0.0
                  if db_refunded_amount == ui_amount
                    message = "We have successfully processed your refund. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding refunds.' : ''}"
                    partial_refund = false
                  else
                    message = "Due to some internal error, We could not processed full refund. Sorry for the inconvenience happend to you. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding partial refund.' : ''} For remaining refund, Please contact to the Ashram."
                    partial_refund = true
                  end

                  # Update request object and attach what has been refunded.
                  refund_other_details[:total_refunded_amount] = db_refunded_amount
                  refund_other_details[:refunds] = refunds
                  refund_other_details[:partial_refund] = partial_refund

                  # Update request object with errors
                  refund_other_details[:errors] = @payment_refund.errors.full_messages

                elsif @t.get_refund_errors.count > 0
                  raise SyException, @t.get_refund_errors.first
                else
                  raise SyException, 'Something went wrong while processing your refund.'
                end
              end

              # Clear all errors as request completed
              @payment_refund.errors.clear

              # Update refunded amount and status and push errors to db if any while updation
              @payment_refund.update(amount_refunded: db_refunded_amount, status: @payment_refund.class.statuses["refunded"], request_object: refund_other_details.deep_merge(request_params))

              # Update registrations and line items
              @payment_refund.perform_updation

              message = "We have successfully processed your request. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding your request.' : ''}"

              # Send refund email
              @payment_refund.reload.refund_email({refunds: refunds, total_refunded_amount: db_refunded_amount, partial_refund: partial_refund}) if @payment_refund.event.try(:notification_service)

              # Request is completed send refund sms
              db_sadhaks.each do |sadhak_profile|

                sadhak_profile.delay.send_sms_to_sadhak("NMS #{sadhak_profile.syid}-#{sadhak_profile.full_name}\nWe have successfully processed your refund for #{event_name_with_location}.")

              end if @payment_refund.event.try(:notification_service)

            rescue SyException => e
              # Delete captured payment refund requeste to allow user to place request again and restore line items updated status
              @payment_refund.update_intermediate_line_item_status(true)

              @payment_refund.update(is_deleted: true)

              Rails.logger.info("EventOrdersController, payment_refunds: errors while restroing line items and event registrations statuses: #{@payment_refund.errors.full_messages}") unless @payment_refund.errors.empty?

              raise SyException, e.message

            rescue Exception => e
              # Delete captured payment refund requeste to allow user to place request again and restore line items updated status
              @payment_refund.update_intermediate_line_item_status(true)

              @payment_refund.update(is_deleted: true)

              Rails.logger.info("EventOrdersController, payment_refunds: errors while restroing line items and event registrations statuses: #{@payment_refund.errors.full_messages}") unless @payment_refund.errors.empty?

              raise Exception, e.message
            end
          end

        rescue Exception => e
          message = e.message
        end

        row << event_order.id
        row << event_order.reg_ref_number
        row << event_order.transaction_id
        row << db_paid_amount.to_f.round(2)
        row << event_order.payment_method
        row << sadhak_profiles.collect{|sp| "SY#{sp[:syid]}"}.join(';')
        row << db_refunded_amount.to_f.round(2)
        row << partial_refund
        row << cancellation_charges_by_policy.to_f.round(2)
        row << @event.try(:automatic_refund?)
        row << @payment_refund.try(:id)
        row << sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]}.join(';')
        row << event_registration_ids
        row << message

        rows << row

      end

      begin

        from = GetSenderEmail.call(@event)

        recipients = [current_user.sadhak_profile.try(:email), current_user.email].extract_valid_emails.uniq

        ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Event #{event_name_with_location} Refund Status.", attachments: {"event-#{id}-#{event_name.parameterize}-refund-report.xls" => generate_excel_file(rows: rows, header: header)}).deliver if rows.size > 0 && recipients.size > 0

      rescue Exception => e
        notify_exception(e)
      end

    rescue Exception => e
      notify_exception(e)
    end

    errors.empty?

  end

  # user_id = 122 Pre-prod: 64
  def transfer_registrations(user_id, to_event_id, excluded_sadhak_profile_ids = [])

    begin

      current_user = User.find_by_id(user_id)

      header = %w(EVENT_ORDER_ID REG_REF_NUMBER TRANSACTION_ID REGISTERD_SADHAK_SYIDS EVENT_ORDER_LINE_ITEM_IDS EVENT_REGISTRATION_IDS TRANSFER_REG_REF_NUMBER TRANSFER_SADHAK_PROFILE_IDS MESSAGE)

      rows = []

      # To block cancellation/upgrade/downgrade of registration if event is global or india clp events.
      clp_event_ids = (GlobalPreference.get_value_of('india_clp_events').to_s.split(',') + GlobalPreference.get_value_of('global_clp_events').to_s.split(',')).map { |id| id.to_i }

      raise "cannot transfer to clp event." if clp_event_ids.include?(to_event_id)

      to_event = Event.find(to_event_id)

      event_seating_category_associations = to_event.event_seating_category_associations

      event_orders.where(id: valid_event_registrations.pluck(:event_order_id)).find_each(batch_size: 1) do |event_order|

        begin

          row = []

          transferred_event_order = nil

          event_order_valid_registrations = event_order.valid_event_registrations

          next if event_order_valid_registrations.size.zero?

          registered_sadhak_ids = event_order_valid_registrations.collect(&:sadhak_profile_id).join(';')
          event_registration_ids = event_order_valid_registrations.collect(&:id).join(';')
          event_order_line_item_ids = event_order_valid_registrations.collect(&:event_order_line_item_id).join(';')
          message = []

          begin

            valid_registrations = event_order_valid_registrations.select do |r|
              valid = true
              if !r.sadhak_profile.present?
                valid = false
                message << "#{r.sadhak_profile_id} not found in database."
              elsif r.sadhak_profile.events.include?(to_event)
                valid = false
                message << "#{r.sadhak_profile_id} - Already registered."
              elsif excluded_sadhak_profile_ids.include?(r.sadhak_profile_id)
                valid = false
                message << "#{r.sadhak_profile_id} - Skipped."
              else
                seating_category = event_seating_category_associations.find{|sc| sc.price == r.event_seating_category_association.price }
                unless seating_category.present?
                  valid = false
                  message << "#{r.sadhak_profile_id} - Seating category not found with same price."
                end
              end
              valid
            end

            # Wrap event_order, line_items, event_registrations, valid and invalid file upload
            ActiveRecord::Base.transaction do

              # Create New event order for all profiles
              _transferred_event_order = to_event.event_orders.create!(user_id: current_user.try(:id), guest_email: event_order.guest_email, registration_center_user_id: event_order.registration_center_user_id)

              # Iterate over valid profiles for registration
              valid_registrations.each_with_index do |r, index|

                # Find category
                event_seating_category_association = event_seating_category_associations.find{|sc| sc.price == r.event_seating_category_association.price }

                # Create event order line item first
                item = _transferred_event_order.event_order_line_items.create!(sadhak_profile_id: r.sadhak_profile_id, seating_category_id: event_seating_category_association.seating_category.id, price: event_seating_category_association.price.try(:to_f), event_seating_category_association_id: event_seating_category_association.id)

                # Create event registration
                event_registration = _transferred_event_order.event_registrations.create!(user_id: event_order.user_id, event_id: to_event.id, event_seating_category_association_id: item.event_seating_category_association_id, sadhak_profile_id: item.sadhak_profile_id, event_order_line_item_id: item.id)

                # Update old line item and registration
                r.update!(status: EventRegistration.statuses[:shivir_changed])
                r.event_order_line_item.update!(status: EventOrderLineItem.statuses[:shivir_changed], transferred_ref_number: _transferred_event_order.reg_ref_number)

              end

              TransferredEventOrder.create!(child_event_order_id: _transferred_event_order.id, parent_event_order_id: event_order.id)

              _transferred_event_order.update!(status: 'success', transaction_id: "TRANSFER_FROM-#{event_order.reg_ref_number}-#{SecureRandom.base64(8).to_s}", payment_method: 'No Payment')

              transferred_event_order = _transferred_event_order

            end

            transferred_event_order.reload.notify_joining if transferred_event_order.present? && transferred_event_order.try(:event).try(:notification_service)

          rescue Exception => e
            message << e.message
          end

          row << event_order.id
          row << event_order.reg_ref_number
          row << event_order.transaction_id
          row << registered_sadhak_ids
          row << event_order_line_item_ids
          row << event_registration_ids
          row << transferred_event_order.reg_ref_number
          row << transferred_event_order.valid_event_registrations.pluck(:sadhak_profile_id).join(';')
          row << message.join(';')

          rows << row

        rescue => e
          p e.backtrace
        end

      end

      begin

        from = GetSenderEmail.call(self)

        recipients = [current_user.sadhak_profile.try(:email), current_user.email].extract_valid_emails.uniq

        ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Event #{event_name_with_location} Transfer Status to #{to_event.event_name_with_location}", attachments: {"event-#{id}-#{event_name.parameterize}-transfer-report-to-#{to_event.id}-#{to_event.event_name.parameterize}.xls" => GenerateExcel.generate(rows: rows, header: header)}).deliver if rows.size > 0 && recipients.size > 0

      rescue => e
        Rollbar.error(e)
      end

    rescue => e
      Rollbar.error(e)
    end

    errors.empty?
  end

  def refund_all_without_cancellation(user_id)
    begin
      rows = []
      @t = TransferredEventOrder
      current_user = User.find_by_id(user_id)
      header = %w(EVENT_ORDER_ID REG_REF_NUMBER TRANSACTION_ID PAID_AMOUNT PAYMENT_METHODS REGISTERD_SADHAK_SYIDS REFUNDED_AMOUNT PARTIAL EVENT_ORDER_LINE_ITEM_IDS EVENT_REGISTRATION_IDS REFUND_DETAILS MESSAGE)
      event_orders.where(id: valid_event_registrations.pluck(:event_order_id)).find_each(batch_size: 1) do |event_order|
        row = []
        refund_other_details = {}
        begin
          next if event_order.valid_event_registrations.count.zero?
          total_refundable_amount = 0.0
          payment_methods = @t.gateways.collect do |g|
            amount = 0
            (Object.const_get g.model).where(event_order_id: event_order.id, status: g[:success]).each do |pt|
              amount += pt.amount
            end
            total_refundable_amount += amount
            amount.nonzero? ? g.payment_method : nil
          end.compact.uniq

          # Perform some validations
          txn_details = @t.get_txn_details(event_order.id)
          db_paid_amount = txn_details.collect{|t| t[:total_paid_amount]}.sum.to_f.round(2)
          ui_amount = total_refundable_amount.to_f.round(2)

          # Raise error if any error while getting transaction details
          raise @t.get_refund_errors.first unless @t.get_refund_errors.empty?

          # Initialize refund_other_details
          refund_other_details[:db_refundable_amount] = ui_amount
          refund_other_details[:action] = "Refund without cancellation"
          refund_other_details[:event_order_id] = event_order.id
          refund_other_details[:db_paid_amount] = db_paid_amount

          if ui_amount > 0.0

            # Process refund
            refund_details = @t.process_refund(txn_details, ui_amount, refund_other_details)
            db_refunded_amount = refund_details[:db_refunded_amount]
            refunds = refund_details[:refunds]

            if db_refunded_amount > 0.0
              if db_refunded_amount == ui_amount
                message = ""
                partial_refund = false
              else
                message = "Due to some internal error, We could not processed full refund. Sorry for the inconvenience. For remaining refund, Please contact to the Ashram."
                partial_refund = true
              end

            elsif @t.get_refund_errors.count > 0
              raise @t.get_refund_errors.first
            else
              raise 'Something went wrong while processing your refund.'
            end
          end
        rescue Exception => e
          message = e.message
        end

        row.push(event_order.id)
        row.push(event_order.reg_ref_number)
        row.push(event_order.transaction_id)
        row.push(db_paid_amount.to_f)
        row.push(payment_methods.join(','))
        row.push(event_order.registered_sadhak_profiles.pluck(:id).join(','))
        row.push(ui_amount.to_f)
        row.push(partial_refund)
        row.push(event_order.event_order_line_item_ids.join(','))
        row.push(event_order.valid_event_registration_ids.join(','))
        row.push(refunds.to_json)
        row.push(message)

        rows.push(row)

        puts row.join('--')
      end
      begin
        from = GetSenderEmail.call(self)
        recipients = [current_user.sadhak_profile.try(:email), current_user.email].extract_valid_emails.uniq
        ApplicationMailer.send_email(recipients: recipients, subject: "Event Refunds without Cancellation - #{event_name} - #{id}", attachments: { "#{id}_#{event_name.parameterize.underscore}_refunded_details_without_cancellation.xls" => GenerateExcel.generate(header: header, rows: rows)}).deliver if recipients.size.nonzero?
      rescue => e
        Rollbar.error(e)
      end
    rescue => e
      Rollbar.error(e)
    end
    errors.empty?
  end

  def in_delhi?
    event.address.present? && event.address.state_name.to_s.downcase.include?(STATE_DELHI.downcase)
  end

  def is_clp_event?
    clp_event_ids = (GlobalPreference.where(key: %w(india_clp_events global_clp_events)).pluck(:val)).map(&:to_i)
    clp_event_ids.include?(id)
  end

  def questionnaire_report
    header = %w(SADHAK_PROFILE_ID EVENT_ID SHIVIR_NAME SHIVIR_START_DATE SHIVIR_END_DATE DATE_OF_BIRTH GENDER COUNTRY STATE CITY PHONE EMAIL_ID EDUCATION PROFESSION/SKILLS ARE_YOU_A_DOCTOR? IF_YES,_WHAT_IS_YOUR_SPECIALIZATION? ARE_YOU_PRACTICING_ANY_OF_THE_FOLLOWING_OR_OTHER_ALTERNATIVE_MEDICINE_MODALITIES? SHIVIR_ATTENDED IF_YOU_ATTENDED_ANY_OTHER_SHIVIR,_PLEASE_MENTION_ITS_NAME ARE_YOU_INTERESTED_IN_BECOMING_SHIV_YOG_COSMIC_THERAPIST_TRAINER)
    rows = row = []
    recipients = GlobalPreference.get_value_of('questionnaire_form_recipients').split(',') || ENV['DEVELOPMENT_RESP']
    date = Date.today
    questionnaires = EventSadhakQuestionnaire.event_id(id).includes(:event, sadhak_profile: {address:[:db_country, :db_state, :db_city]})
    questionnaires.each do |questionnaire|
      row = []
      data = questionnaire.data.with_indifferent_access
      row.push(questionnaire.sadhak_profile_id)
      row.push(questionnaire.event_id)
      row.push(questionnaire.event.event_name)
      row.push(questionnaire.event.event_start_date)
      row.push(questionnaire.event.event_end_date)
      row.push(questionnaire.sadhak_profile.date_of_birth)
      row.push(questionnaire.sadhak_profile.gender.try(:humanize))
      questionnaire.sadhak_profile.address.tap do |address|
        row.push(address.country_name)
        row.push(address.state_name)
        row.push(address.city_name)
      end
      row.push(data[:phone] || '')
      row.push(data[:email_id] || '')
      row.push(data[:education] || '')
      row.push(data[:profession_skills] || '')
      row.push(data[:is_doctor] || '')
      row.push(data[:specialization] || '')
      row.push((data[:medicine_modalities] || '').join(', '))
      row.push((data[:attended_shivir] || '').join(', '))
      row.push(data[:attended_other_shivir] || '')
      row.push(data[:can_be_therapist] || '')
      rows.push(row)
    end
    attachments = {}
    file_name = "questionnaire_form_report-#{DateTime.now.strftime('%F %T')}"
    file = EventRegistration.generate_excel_file(rows: rows, header: header)
    {file: file, file_name: file_name}
  end

  def event_address
    if self.address.present?
      (self.address.first_line.present? ? (self.address.first_line + ",") : "") + (self.address.second_line.present? ? (self.address.second_line + ", ") : "") + (self.address.db_city.name.present? ? (self.address.db_city.name + ", ") : "") + (self.address.db_state.name.present? ? (self.address.db_state.name + "-") : "") + (self.address.postal_code.present? ? (self.address.postal_code + " ") : "") + self.address.db_country.name
    end
  end

  private

  def after_event_save
    if !self.bhandara_detail.nil?
      self.bhandara_detail.update_bhandara_items
    end
  end

end
