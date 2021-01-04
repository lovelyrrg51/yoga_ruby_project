class EventRegistration < ApplicationRecord
  include AASM
  acts_as_paranoid

  def paranoia_restore_attributes
    {
      deleted_at: nil,
      is_deleted: false
    }
  end

  def paranoia_destroy_attributes
    {
      deleted_at: current_time_from_proper_timezone,
      is_deleted: true
    }
  end

  # Papertrail logging
  has_paper_trail class_name: 'EventRegistrationVersion', only: [:user_id, :event_id, :special_considerations, :event_seating_category_association_id, :sadhak_profile_id, :event_order_id, :status, :is_extra_seat, :event_order_line_item_id, :is_deleted, :has_attended, :invoice_number, :serial_number, :sy_event_company_id], on: [:update, :destroy]

  diff :user_id, :event_id, :special_considerations, :event_seating_category_association_id, :sadhak_profile_id, :event_order_id, :status, :is_extra_seat, :event_order_line_item_id, :is_deleted, :has_attended, :invoice_number, :serial_number, :sy_event_company_id, :updated_at

  belongs_to :event
  belongs_to :user, optional: true
  belongs_to :sadhak_profile
  belongs_to :event_order_line_item, dependent: :destroy, optional: true
  belongs_to :event_seating_category_association, optional: true
  has_one :seating_category, through: :event_seating_category_association
  belongs_to :event_order, optional: true
  belongs_to :sy_event_company, optional: true
  has_many :attachments, as: :attachable, dependent: :destroy
  has_one :sy_club_member, dependent: :destroy
  has_one :parent_registration, class_name: 'EventRegistration', foreign_key: 'id', primary_key: 'renewed_from'
  has_one :child_registration, class_name: 'EventRegistration', foreign_key: 'renewed_from'
  delegate :rgba, to: :seating_category, allow_nil: true
  delegate :reg_ref_number, to: :event_order, allow_nil: true
  delegate :event_start_date, to: :event, allow_nil: true
  delegate :event_end_date, to: :event, allow_nil: true
  delegate :event_name, to: :event, allow_nil: true
  delegate :event_location, to: :event, allow_nil: true

  # From old portal: invoice feature
  has_many :vouchers, as: :receiptable, dependent: :destroy
  has_one :receipt_voucher, lambda { where(vouchers: {voucher_type: Voucher.voucher_types[:receipt]}).order('vouchers.id DESC') }, as: :receiptable, class_name: 'Voucher'
  has_one :receipt_voucher_attachment, through: :receipt_voucher, source: :attachment
  has_one :invoice_voucher, lambda { where(vouchers: {voucher_type: Voucher.voucher_types[:invoice]}).order('vouchers.id DESC') }, as: :receiptable, class_name: 'Voucher'
  has_one :invoice_voucher_attachment, through: :invoice_voucher, source: :attachment
  has_one :refund_voucher, lambda { where(vouchers: {voucher_type: Voucher.voucher_types[:refund]}).order('vouchers.id DESC') }, as: :receiptable, class_name: 'Voucher'
  has_one :refund_voucher_attachment, through: :refund_voucher, source: :attachment
  has_one :payment_refund_line_item, lambda{ order('id DESC').limit(1) }
  delegate :price, to: :event_seating_category_association, allow_nil: true

  validates_uniqueness_of :sadhak_profile_id, :scope => :event_order_id,  conditions: -> { where(status: EventRegistration.valid_registration_statuses) }

  before_create :assign_line_item_serial_number_and_company
  after_create :notify_registration, if: Proc.new { |er| er.is_production? and er.event.try(:notification_service)}

  after_create :generate_vouchers, if: Proc.new { |er| er.sy_event_company_id.present? && er.event.paid? && er.event.is_in_india? }

  after_create :perform_forum_registration, if: Proc.new { |er| er.event_order.sy_club_id.present? }
  before_create :renew_registration_status, if: Proc.new { |er| er.event_order.sy_club_id.present? }

  before_create :assign_serial_number

  # Cancel forum membership callback
  before_save :cancel_forum_membership, if: Proc.new { |er| status_changed? and (er.cancelled? or er.cancelled_refunded?) }

  # Update seating category by action cable
  after_commit :broadcast_seats_available

  # generate vouchers when registration status update
  after_update :generate_vouchers_if_status_changed, if: ->(er){ status_changed? && er.event.paid? && er.event.is_in_india? && er.sy_event_company_id.present?}
  # Scopes
  scope :event_id, lambda { |event_id| where(event_registrations: {event_id: event_id}) }
  scope :first_name, lambda { |first_name| joins(:sadhak_profile).where('sadhak_profiles.first_name ILIKE ?', "%#{first_name.to_s.strip}%" ) }
  scope :full_name, ->(full_name) { joins(:sadhak_profile).where("sadhak_profiles.first_name ILIKE :full_name OR sadhak_profiles.last_name ILIKE :full_name OR (sadhak_profiles.first_name || '' || sadhak_profiles.last_name) ILIKE :full_name", full_name: "%#{full_name.to_s.gsub(/\s+/, "")}%") }
  scope :payment_method, lambda { |payment_method| joins(:event_order).where('event_orders.payment_method ILIKE ?', "%#{payment_method.to_s.strip}%") }
  scope :reg_ref_number, lambda { |reg_ref_number| joins(:event_order).where(event_orders: {reg_ref_number: reg_ref_number.to_s.strip}) }
  scope :transaction_id, lambda { |transaction_id| joins(:event_order).where(event_orders: {transaction_id: transaction_id.to_s.strip}) }
  scope :status, lambda { |status| where(event_registrations: {status: status}) }
  scope :syid, ->(syid) { joins(:sadhak_profile).where("sadhak_profiles.syid ILIKE ?", "%#{syid.to_s.strip}%") }
  scope :invoice_number, ->(invoice_number) { where(invoice_number: invoice_number) }
  scope :reg_invoice_from, ->(reg_invoice_from) { where("event_registrations.created_at::date >= ?", reg_invoice_from)}
  scope :reg_invoice_to, ->(reg_invoice_to) { where("event_registrations.created_at::date <= ?", reg_invoice_to)}
  scope :reg_invoice_event, ->(reg_invoice_event) { joins(:event).where(events: {id: reg_invoice_event})}

  scope :expired_from, -> (expired_from) {
    expired
    .where("event_registrations.created_at + interval '1 day' * event_registrations.expires_at >= ?", expired_from.to_date + 1 ) }

  scope :expired_to, -> (expired_to) {
    expired
    .where("event_registrations.created_at + interval '1 day' * event_registrations.expires_at <= ?", expired_to.to_date + 2) }


  # Enums
  enum status:{cancelled: 0, transferred: 1, updated: 2, success: 3, cancelled_refunded: 4, cancelled_refund_pending: 5, upgraded: 6, downgraded: 7, name_changed: 8, shivir_changed: 9, downgrade_requested: 10, shivir_change_requested: 11, name_change_requested: 12, upgrade_requested: 13, expired: 14, renewed: 15}


  include AASM
  aasm :column => :status, :enum => true do
    state :success, :initial => true
    state :cancelled
    state :transferred
    state :updated
    state :cancelled_refunded
    state :cancelled_refund_pending
    state :upgraded
    state :downgraded
    state :name_changed
    state :shivir_changed
    state :downgrade_requested
    state :shivir_change_requested
    state :name_change_requested
    state :upgrade_requested
    state :expired
    state :renewed
  end

  def assign_line_item_serial_number_and_company
    self.event_order_line_item = EventOrderLineItem.where(event_order_id: event_order_id, sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: event_seating_category_association_id).last
    self.serial_number = event.event_registrations.count + 1
    self.sy_event_company = event.sy_event_company
    errors.empty?
  end

  def do_generate_event_registration_file(event, no_masking, admin, format, from = nil, to = nil)
    # Assign default value to from and to
    from = from.present? ? from : (Date.today - 10.years).to_s
    to = to.present? ? to : (Date.today + 10.years).to_s

    # Get demand draft details if payment made by demand draft
    payment_methods = event.event_orders.collect{|eo| eo.payment_method}
    dd_txns = PgSyddTransaction.where(event_order_id: event.event_order_ids)
    currency = event.pay_in_usd? ? 'USD' : event.try(:address).try(:db_country).try(:currency_code)
    # Generate common header for doctor's + regular event.
    if no_masking
      header = %W(REGISTRATION_NUMBER RECEIPT_NO INVOICE_NO OLD_SYID OLD_FIRST_NAME OLD_LAST_NAME NEW_SYID NEW_FIRST_NAME NEW_LAST_NAME NEW_GENDER NEW_DATE_OF_BIRTH NAME_CHANGED_DATE NEW_MOBILE NEW_EMAIL NEW_COUNTRY NEW_STATE NEW_CITY NEW_STREET_ADDRESS OLD_TRANSACTION_ID NEW_TRANSACTION_ID DATE_OF_TRANSACTION OLD_SEATING_CATEGORY NEW_SEATING_CATEGORY OLD_CATEGORY_AMOUNT(#{currency}) NEW_CATEGORY_AMOUNT(#{currency}) OLD_DISCOUNT(#{currency}) NEW_DISCOUNT(#{currency}) DIFFERENCE_AMOUNT(PAID/REFUNDED) TOTAL_TAX(#{currency}) CONVIENENCE_CHARGES(#{currency}) TOTAL_PAID(#{currency}) REGISTRATION_STATUS REG_REF_NUMBER REGISTRATION_DATE EVENT_NAME EVENT_START_DATE EVENT_END_DATE PAYMENT_STATUS PAYMENT_METHOD REGISTRATION_ID ITEM_ID IS_FORUM_MEMBER IS_FORUM_BOARD_MEMBER FORUM_ID FORUM_NAME)

    else
      header = %W(REGISTRATION_NUMBER SYID FIRST_NAME LAST_NAME MOBILE EMAIL COUNTRY STATE CITY TRANSACTION_ID SEATING_CATEGORY CATEGORY_AMOUNT(#{currency}) DISCOUNT(#{currency}) REGISTRATION_STATUS REG_REF_NUMBER REGISTRATION_DATE EVENT_NAME EVENT_START_DATE EVENT_END_DATE RECEIPT_NO INVOICE_NO PAYMENT_STATUS)
    end

    # Add doctor's header if event is doctor's event
    if event.event_type.name == 'Doctors Event'.downcase
      header += %w(MEDICAL_DEGREE CURRENT_PROFESSION WORK_ENVIRONMENT SPECIALITY_AREA)
    end

    # Add demand draft details if payment made by demand draft
    if no_masking and payment_methods.include?('Demand draft')
      header += %w(BANK_NAME ADMIN_NOTES DD_DATE REGISTERED_BY)
    end

    if no_masking
      # Add event categories name
      header += event.seating_categories.collect{|cat| cat.category_name}.map(&:upcase)
    end

    if event.address.try(:country_id) == 113
      header += %w(INVOICE_DATE)
    end

    # Hold generated rows
    # rows = []

    # Hold registration centers
    registration_centers = {}

    # Iterate over event registrations with status [nil, updated]
    includable_data = [{sadhak_profile: [{ address: [:db_city, :db_state, :db_country] }, {medical_practitioners_profile: [:medical_practitioner_speciality_area]}]}, {event_order: [:registration_center_user, :registration_center, :event_registrations, :versions]}, {event_order_line_item: [:versions]}, :event_seating_category_association, :seating_category, :user, :versions, {event: [:event_seating_category_associations, :seating_categories, { address: [:db_city, :db_state, :db_country] }, {registration_centers: [:registration_center_users]}, :event_tax_type_associations, :tax_types]}, {sy_club_member: [:sy_club]}, :vouchers, :invoice_voucher, :receipt_voucher]

    if event.sy_event_company_id.present?
      if event.is_in_india?
        if event.is_clp_event?
          @event_registrations = EventRegistration.where(event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded', 'renewed', 'expired').values)).where('created_at >= ? AND created_at <= ?', from.present? ? DateTime.parse(from.to_s << " 12am IST").at_beginning_of_day : from, to.present? ? DateTime.parse(to.to_s << " 12pm IST").at_end_of_day : to).order('serial_number').includes(includable_data)
        else
          @event_registrations = EventRegistration.where(event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded', 'renewed').values)).where('created_at >= ? AND created_at <= ?', from.present? ? DateTime.parse(from.to_s << " 12am IST").at_beginning_of_day : from, to.present? ? DateTime.parse(to.to_s << " 12pm IST").at_end_of_day : to).order('serial_number').includes(includable_data)
        end

      else
        @event_registrations = EventRegistration.where(event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded', 'renewed').values)).where('created_at::date >= ? AND created_at::date <= ?', from, to).order('serial_number').includes(includable_data)
      end
    else
      @event_registrations = EventRegistration.where(event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded', 'renewed').values)).where('created_at::date >= ? AND created_at::date <= ?', from, to).order('event_order_line_item_id').includes(includable_data)
    end

    if format == 'csv'
      CSV(csv = '')   { |csv_str| csv_str << header }
    else
      # Generate Spreadsheet
      spreadsheet = Spreadsheet::Workbook.new

      # Create workbook
      report = spreadsheet.create_worksheet(:name => 'List of members')

      # Input headers
      header.each do |column|
        report.row(0).concat %W{#{column}}
      end

      # Set header format
      header_format = Spreadsheet::Format.new(color: 'red', weight: 'bold')

      # Make it is default heaer format
      report.row(0).default_format = header_format

    end

    @event_registrations.each_with_index do |_registration, _index|
      begin

        # Hold single row
        row = []

        # Details for specific payment of demand draft
        @dd_data = dd_txns.find{|dd| dd.event_order_id == _registration.event_order_id}

        # Get sadhak profile
        sadhak_profile = _registration.sadhak_profile
        _registration_version = _registration.versions.last.try(:reify)
        old_sadhak_profile = _registration_version.try(:sadhak_profile)
        is_syid_changed = (old_sadhak_profile.present? and sadhak_profile.id != old_sadhak_profile.id)

        # Get sadhak profile address
        sadhak_address = sadhak_profile.try(:address)

        # Get event order associated to current registration
        event_order = _registration.event_order

        event_order_version = nil
        if _registration.status == 'upgraded'
          (event_order.try(:versions) || []).reverse.each do |eov|
            if eov.reify.diff(event_order)[:transaction_id].present?
              event_order_version = eov.reify
              break
            end
          end
        else
          event_order_version = event_order.try(:versions).try(:last).try(:reify)
        end

        is_transaction_id_changed = (event_order_version.present? and event_order.try(:transaction_id) != event_order_version.transaction_id)

        # Get registred seating category assosciation
        seating_category_association = _registration.event_seating_category_association
        old_seating_category_association = _registration_version.try(:event_seating_category_association)
        is_category_changed = (old_seating_category_association.present? and seating_category_association.try(:id) != old_seating_category_association.try(:id))

        # Get registred seating category
        seating_category = _registration.seating_category
        old_seating_category = old_seating_category_association.try(:seating_category)

        # Get event order line item
        event_order_line_item = _registration.event_order_line_item
        event_order_line_item_version = event_order_line_item.try(:versions).try(:last).try(:reify)

        # Push serial number that will 100 plus if company attached else registration number
        # REGISTRATION_NUMBER
        row.push(if event.sy_event_company_id.present? then
                     _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : 'NA'
                   else
                    _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : 'NA'
                    # depricated: request from sandeep ji
                     # event_order_line_item.try(:registration_number).present? ? event_order_line_item.registration_number : 'NA'
                   end)

        # Push data according to header
        if no_masking

          # RECEIPT_NO
          row.push(_registration.try(:receipt_voucher_number))

          # INVOICE_NO
          row.push(_registration.try(:invoice_voucher_number))

          # OLD_SYID
          row.push(is_syid_changed ? old_sadhak_profile.try(:syid) : nil)

          # OLD_FIRST_NAME
          row.push(is_syid_changed ? old_sadhak_profile.try(:first_name) : nil)

          # OLD_LAST_NAME
          row.push(is_syid_changed ? old_sadhak_profile.try(:last_name) : nil)
        end

        # NEW_SYID/SYID
        row.push(sadhak_profile.try(:syid))

        # NEW_FIRST_NAME/FIRST_NAME
        row.push(sadhak_profile.try(:first_name))

        # NEW_LAST_NAME/LAST_NAME
        row.push(sadhak_profile.try(:last_name))

        if no_masking
          # NEW_GENDER
          row.push(sadhak_profile.try(:gender))

          # NEW_DATE_OF_BIRTH
          row.push(sadhak_profile.try(:date_of_birth).try(:strftime, '%d/%m/%Y'))

          # NAME_CHANGED_DATE
          row.push(is_syid_changed ? _registration_version.try(:version).try(:created_at).try(:strftime, '%d/%m/%Y') : nil)
        end

        if no_masking && admin
          # NEW_MOBILE
          row.push(sadhak_profile.try(:mobile))

          # NEW_EMAIL
          row.push(sadhak_profile.try(:email))
        else
          # MOBILE
          row.push(sadhak_profile.try(:mobile).to_s.gsub!(/.(?=....)/, '*'))
          if sadhak_profile.email.present?
            sadhak_email = sadhak_profile.try(:email).split('@')
            email_text = sadhak_email[0]
            if email_text.present? and email_text.length > 2
              temp = '*' * (email_text.length-2)
              text = email_text[0].to_s + temp + email_text[email_text.length-1].to_s + '@' + sadhak_email[1].to_s
            else
              text = '*****************@' + sadhak_email[1].to_s
            end
            email = text
          else
            email = 'NA'
          end
          # EMAIL
          row.push(email)
        end

        # To check whether masking is applicable or not
        # NEW_COUNTRY
        row.push(sadhak_address.try(:country_name))

        # NEW_STATE
        row.push(sadhak_address.try(:state_name))

        # NEW_CITY
        row.push(sadhak_address.try(:city_name))

        if no_masking

          # NEW_STREET_ADDRESS
          row.push(admin ? sadhak_address.try(:street_address) : nil)

          # OLD_TRANSACTION_ID
          row.push(is_transaction_id_changed ? event_order_version.try(:transaction_id) : nil)
        end

        # NEW_TRANSACTION_ID/TRANSACTION_ID
        row.push(event_order.try(:transaction_id))

        if no_masking
          # DATE_OF_TRANSACTION
          row.push(event_order_version.try(:version).try(:created_at).to_s)

          # OLD_SEATING_CATEGORY
          row.push(is_category_changed ? old_seating_category.try(:category_name) : nil)
        end

        # NEW_SEATING_CATEGORY/SEATING_CATEGORY
        row.push(seating_category.try(:category_name))

        # OLD_CATEGORY_AMOUNT
        row.push(is_category_changed ? ('%.2f' % old_seating_category_association.try(:price).to_f) : nil) if no_masking

        # NEW_CATEGORY_AMOUNT/CATEGORY_AMOUNT
        row.push('%.2f' % seating_category_association.try(:price).to_f)

        # OLD_DISCOUNT
        row.push(event_order_line_item_version.present? ? ('%.2f' % event_order_line_item_version.try(:discount).to_f) : nil) if no_masking

        # NEW_DISCOUNT/DISCOUNT
        row.push('%.2f' % event_order_line_item.try(:discount).to_f)

        if no_masking

          # DIFFERENCE_AMOUNT(PAID/REFUNDED)
          amount_diff = is_category_changed ? (old_seating_category_association.try(:price).to_f - seating_category_association.try(:price).to_f): nil
          paid_or_refunded = if amount_diff.present? then
                               if amount_diff < 0 then
                                 ' - PAID'
                               else
                                 amount_diff > 0 ? ' - REFUNDED' : nil
                               end
                             else
                               nil
                             end
          row.push(paid_or_refunded.present? ? (('%.2f' % amount_diff.to_f.abs) + paid_or_refunded) : nil)

          total_tax_detail = (event_order_line_item.try(:total_tax_detail) || {}).deep_symbolize_keys

          # TOTAL_TAX
          row.push('%.2f' % total_tax_detail[:total_tax_paid].to_f)

          # CONVIENENCE_CHARGES
          row.push('%.2f' % total_tax_detail[:total_convenience_charges].to_f)

          # TOTAL_PAID
          row.push('%.2f' % (seating_category_association.try(:price).to_f - event_order_line_item.try(:discount).to_f + total_tax_detail[:total_tax_paid].to_f + total_tax_detail[:total_convenience_charges].to_f))

        end

        # REGISTRATION_STATUS
        row.push(_registration.status.present? ? EventOrder.template_status_mapper[_registration.status.to_s] : 'Success')

        row.push(event_order.try(:reg_ref_number))

        row.push(_registration.try(:created_at).try(:to_s))

        row.push(event.try(:event_name))

        row.push(event.try(:event_start_date).try(:to_s))

        row.push(event.try(:event_end_date).try(:to_s))

        unless no_masking

          # RECEIPT NO
          row.push(_registration.try(:receipt_voucher_number))

          # INVOICE NO
          row.push(_registration.try(:invoice_voucher_number))

        end

        row.push(event_order.try(:status))

        if no_masking
          row.push(event_order.try(:payment_method))

          # Push registration id and item id for debugging purpose
          row.push(_registration.id)
          row.push(event_order_line_item.try(:id))

          # IS_FORUM_MEMBER
          row.push(sadhak_profile.try(:active_club_ids).present? ? 'Yes' : 'No')

          # IS_FORUM_BOARD_MEMBER
          row.push(sadhak_profile.try(:sy_clubs).present? ? 'Yes' : 'No')

          # FORUM_ID
          row.push(sadhak_profile.try(:active_club).try(:id) || "")

          # FORUM_NAME
          row.push(sadhak_profile.try(:active_club).try(:name) || "")

        end

        # If event is doctor's event
        if event.event_type.name == 'Doctors Event'.downcase

          # MEDICAL_DEGREE
          medical_practitioners_profile = sadhak_profile.try(:medical_practitioners_profile)
          row.push(medical_practitioners_profile.try(:medical_degree))

          # CURRENT_PROFESSION
          row.push(medical_practitioners_profile.try(:current_professional_role))

          # WORK_ENVIRONMENT
          row.push(medical_practitioners_profile.try(:work_enviroment))

          # SPECIALITY_AREA
          medical_practitioner_speciality_area = medical_practitioners_profile.try(:medical_practitioner_speciality_area)
          row.push(medical_practitioner_speciality_area.present? ? medical_practitioner_speciality_area.try(:name) : medical_practitioners_profile.try(:other_speciality))
        end

        # if Payment made usning demand draft
        if no_masking and event_order.payment_method == 'Demand draft'

          row.push(@dd_data.try(:bank_name)) rescue 'NA'

          row.push(@dd_data.try(:additional_details)) rescue 'NA'

          row.push(@dd_data.try(:dd_date).to_s) rescue 'NA'

          # Increase efficency to find registration center - Start

          registration_center = nil

          if event_order.user_id.present?
            # Load registration center details form object
            registration_center = registration_centers["#{_registration.event_id}-#{event_order.user_id}"]

            # if not found then load from database and keep a copy of it
            unless registration_center.present?

              event_order.registration_center_user_id = _registration.event.get_registration_center_user_id(event_order.user_id)

              registration_center = event_order.registration_center

              registration_centers["#{_registration.event_id}-#{event_order.user_id}"] = registration_center if registration_center.present?

            end
          end

          # Increase efficency to find registration center - End

          row.push(event_order.try(:user).try(:sadhak_profile).try(:syid).to_s + '-' + registration_center.try(:name).to_s) rescue 'NA'
        end

        # Category logic
        if no_masking
          category_index = header.index(seating_category.try(:category_name).try(:upcase))
          row[category_index] = 1 if category_index.present?
        end

        if event.address.try(:country_id) == 113
          row.push(_registration.invoice_voucher.try(:created_at))
        end

        # Push single row to array
        # rows.push(row)

        if format == 'csv'
          csv << (row.join(',') + "\n")
        else
          row.each do |_r|
            report.row(_index+1).push(_r)
          end
        end
      rescue Exception => e
        logger.info("EventRegistration #do_generate_event_registration_file: error: #{e.message} at #{_index} with event_registration id: #{_registration.try(:id)}")
        raise e.message
      end
    end

    blob = StringIO.new()

    if format == 'csv'
      blob = csv
    else
      # Write spreadsheet
      spreadsheet.write blob
      blob = blob.string
    end
    # return {header: header, rows: rows}
    return blob
  end

  def process_report_generate(params)
    # Get event
    event = Event.preloaded_data.find_by_id(params[:event_id])

    user = User.find_by_id(params[:user_id])

    # Generate registrations data.
    blob = do_generate_event_registration_file(event, true, user.try(:super_admin?), params[:format], params[:from], params[:to])

    if params[:send_email].present? and params[:recipients].present?
      begin
        from = GetSenderEmail.call(event)
        ApplicationMailer.send_email(from: from, recipients: params[:recipients], subject: "Event Registration Report: #{event.try(:event_name)}-#{event.try(:id)} - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", attachments: Hash["#{event.event_name}_registrations_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.#{params[:format]}", blob]).deliver
      rescue => e
        Rails.logger.info("Some error ocuured while sending email: EventOrdersController #generate_csv, error: #{e.message}")
        Rollbar.error(e)
      end
    end

    return blob if params[:download]
  end

  def self.preloaded_data
    EventRegistration.includes(EventRegistration.includable_data)
  end

  def self.includable_data
    [{sadhak_profile: [{ address: [:db_city, :db_state, :db_country] }, {medical_practitioners_profile: [:medical_practitioner_speciality_area]}, :professional_detail]}, {event_order: [:registration_center_user, :registration_center, :event_registrations]}, :event_order_line_item, :event_seating_category_association, :seating_category, :user, {event: [:event_seating_category_associations, :seating_categories, { address: [:db_city, :db_state, :db_country] }, {registration_centers: [:registration_center_users]}, :event_tax_type_associations, :tax_types]}]
  end

  def assign_serial_number
    self.serial_number = self.try(:event).event_registrations.count + 1
    errors.empty?
  end

  def notify_registration
    if self.event_order.try(:sy_club_id).present?
      club = self.event_order.sy_club
      message = "NMS #{sadhak_profile.full_name.try(:titleize)}-#{sadhak_profile.syid}\nYou have successfully #{self.parent_registration.present? ? 'renewed your membership' : 'registered'} on #{club.name}. Membership expires on #{self.expiration_date}"
    else
      message = "NMS #{sadhak_profile.full_name.try(:titleize)}-#{sadhak_profile.syid}\nYou have successfully registered with Reg no: #{self.event.sy_event_company_id.present? ? (self.serial_number + 100) : self.event_order_line_item_id}, Ref no: #{self.event_order.reg_ref_number} on shivir #{self.event.event_name}."
    end
    sadhak_profile.send_sms_to_sadhak(message)
  rescue => e
    Rollbar.error(e)
  end
  handle_asynchronously :notify_registration

  def is_production?
    %w(production testing).include?(ENV['ENVIRONMENT'])
  end

  def receipt_voucher_number
    receipt_voucher_number = ""
    if receipt_voucher.try(:voucher_number).present?
      voucher_prefix = sy_event_company.try(:receipt_prefix)
      voucher_prefix = gen_voucher_prefix_if_not_in_company("receipt") unless voucher_prefix.present?
      receipt_voucher_number = voucher_prefix + ("%09d" % receipt_voucher.try(:voucher_number).to_s.to_i)
      voucher_prefix = "AD/" + receipt_voucher_number  if event.next_financial_year?
    end
    receipt_voucher_number
  end


  def invoice_voucher_number
    invoice_voucher_number = ""
    if invoice_voucher.try(:voucher_number).present?
      voucher_prefix = sy_event_company.try(:invoice_prefix)
      voucher_prefix = gen_voucher_prefix_if_not_in_company("invoice") unless voucher_prefix.present?
      invoice_voucher_number = voucher_prefix + ("%09d" % invoice_voucher.try(:voucher_number).to_s.to_i)
    end
    invoice_voucher_number
  end

  # method to generate pdf invoice payment receipt
  def generate_invoice_data

    # Create hash that will hold data passed to template
    invoice = Hash.new
    begin
      # Collect required information
      event_company = sy_event_company

      detail = ((event_order.try(:transaction_logs).try(:last).try(:request_params).try(:deep_symbolize_keys) || {})[:details] || []).find{|f| f[:discounted_line_item_id].to_i == event_order_line_item_id} || {}
      taxes = []

      # Find gateway
      gateway = TransferredEventOrder.gateways.find {|g| g[:payment_method].to_s == event_order.payment_method.to_s}

      # Find config id of payment gateway
      config_id = TransferredEventOrder.get_gateway_config_id(event_order.id, gateway[:config_model]) if gateway.present? and gateway[:gateway_type] == 'online'

      # Collect some information that is needed to generate invoice
      transaction = gateway.present? ? gateway[:model].constantize.send("find_by_#{gateway[:transaction_id]}", event_order.transaction_id) : nil

      is_clp_event = event.get_clp_detail[:is_clp_event]

      invoice[:company_name] = event_company.try(:name)

      invoice[:company_address] = event_company.try(:address).try(:street_address)

      invoice[:company_city] = event_company.try(:address).try(:city_name)

      invoice[:company_state] = event_company.try(:address).try(:state_name)

      invoice[:company_country] = event_company.try(:address).try(:country_name)

      invoice[:zipcode] = event_company.try(:address).try(:postal_code)

      invoice[:is_forum] = false

      Voucher.voucher_types.each do |k, v|

        _voucher = self.try("#{k}_voucher")

        next unless _voucher.present?

        invoice[:place_of_supply] = event.address.try(:state_name).to_s.downcase
        if is_clp_event
          # Forum
          invoice[:shivir_type] = 'forum'
          invoice[:place_of_supply] = sadhak_profile.try(:active_club).try(:address).try(:state_name).to_s.downcase
          invoice[:is_forum] = true

        elsif event.graced_by == 'Subtle presence of Babaji'
          # Live or Online Shivir
          invoice[:shivir_type] = 'onlive_shivir'
        else
          # Main Shivir
          invoice[:shivir_type] = 'main_shivir'
        end

        voucher_prefix = event_company.try(k + "_prefix")
        voucher_prefix = gen_voucher_prefix_if_not_in_company(k) unless voucher_prefix.present?
        voucher_prefix = "AD" << voucher_prefix if event.next_financial_year?
        invoice["#{k}_voucher_number"] = voucher_prefix << _voucher.voucher_number

        invoice["#{k}_voucher_date"] = _voucher.created_at.strftime('%d-%m-%Y')

      end

      invoice[:contact_email] = GetSenderEmail.call(event)

      invoice[:llpin_number] = event_company.try(:llpin_number)

      invoice[:company_gstin_number] = event_company.try(:gstin_number)

      invoice[:sadhak_full_name] = sadhak_profile.try(:full_name)

      invoice[:sadhak_syid] = sadhak_profile.try(:syid)

      invoice[:sadhak_state] = sadhak_profile.try(:address).try(:state_name)

      invoice[:sadhak_city] = sadhak_profile.try(:address).try(:city_name)

      invoice[:sadhak_full_address] = sadhak_profile.try(:address).try(:full_address)

      invoice[:event_name] = is_clp_event ? event_order.try(:sy_club).try(:name) : event.try(:event_name)

      invoice[:expiration_date] = sadhak_profile.expiration_date


      invoice[:event_name_with_location] = "#{event.try(:event_name_with_location)}"

      invoice[:event_start_date] = event.try(:event_start_date).try(:strftime, '%d-%m-%Y')

      invoice[:event_end_date] = event.try(:event_end_date).try(:strftime, '%d-%m-%Y')

      if is_clp_event
        invoice[:validity] = created_at.strftime('%b %d, %Y') + " to " + invoice[:expiration_date]
      else
        invoice[:validity] = invoice[:event_start_date] + " to " + invoice[:event_end_date]
      end

      invoice[:seating_category] = seating_category.try(:category_name)

      invoice[:place_of_shivir] = is_clp_event ? event_order.try(:sy_club).try(:name) + " to be held #{invoice[:validity]}" : event.address.try(:full_address)

      invoice[:basic_fee] = price.to_f.round(2)

      invoice[:discount] = detail[:discount].to_f.round(2)

      # Check if it is Upgradation
      if upgraded?
        invoice[:seating_category] = "Upgraded to #{seating_category.try(:category_name)}"
        invoice[:basic_fee] = event_order.tax_details.original_amount.to_f.round(2)
      end

      if downgraded?
        invoice[:seating_category] = "Downgraded to #{seating_category.try(:category_name)}"
        invoice[:basic_fee] = event_order.tax_details.original_amount.to_f.round(2)
      end

      invoice[:net_fee] = invoice[:basic_fee] - invoice[:discount]

      taxable_amount = invoice[:net_fee].to_f.round(2)

      (event_order_line_item.tax_types || []).each do |tax_association|
        tax_association = tax_association.deep_symbolize_keys
        taxes.push({tax_type_name: tax_association[:tax_type_name], percent: tax_association[:percent], tax_amount: ((taxable_amount * tax_association[:percent].to_f)/100).to_d.round(2, :truncate).to_f})
      end

      invoice[:tax_applicable] = taxes.collect{|t| t[:tax_amount].to_f}.sum
      invoice[:tax_applicable] = 0.0 if event.free? || cancelled_refunded? || downgraded?

      is_tax_applicable = !invoice[:tax_applicable].zero?
      # Assign taxes
      invoice[:taxes] = taxes

      if !invoice[:sadhak_state].try(:include?, STATE_DELHI) && ((event.graced_by == 'Subtle presence of Babaji') || is_clp_event)

        invoice[:cgst] = {}

        invoice[:sgst] = {}

        invoice[:igst] = {tax_type_name: 'IGST', percent: '18', tax_amount: is_tax_applicable ? ((taxable_amount * 18)/100).round(2) : 0}

      else

        invoice[:cgst] = {tax_type_name: 'CGST', percent: '9', tax_amount: is_tax_applicable ? ((taxable_amount * 9)/100).round(2) : 0}

        invoice[:sgst] = {tax_type_name: 'SGST', percent: '9', tax_amount: is_tax_applicable ? ((taxable_amount * 9)/100).round(2) : 0}

        invoice[:igst] = {}

      end

      invoice[:paid_amount_with_all_charges] = (taxable_amount + invoice[:tax_applicable])

      invoice[:transaction_number] = event_order.try(:transaction_id)

      invoice[:reg_ref_number] = event_order.try(:reg_ref_number)

      invoice[:payment_date] = transaction.try(:created_at).try(:to_date).try(:strftime, '%d-%m-%Y')

      invoice[:recieved_amount] = transaction.try(:amount).to_f.round(2)

      invoice[:demand_draft_number] = transaction.try(:dd_number)

      invoice[:demand_draft_bank_name] = transaction.try(:bank_name)

      invoice[:demand_draft_dated] = transaction.try(:dd_date)

      invoice[:mode_of_payment] = gateway.present? ? gateway[:gateway_type].to_s == "offline" ? gateway[:payment_method].to_s.titleize : gateway[:gateway_type].to_s.titleize : "NA"

      invoice[:gateway_config] = config_id.present? ? gateway[:config_model].classify.constantize.find_by_id(config_id) : nil

      invoice[:convienence_charges] = invoice[:gateway_config].try(:tax_amount).present? ? (invoice[:paid_amount_with_all_charges] * invoice[:gateway_config].try(:tax_amount).to_f / 100) : 0.00
      invoice[:convienence_charges] = 0.0 unless is_tax_applicable

    rescue => e
      Rollbar.error(e)
    end

    invoice.with_indifferent_access
  end

  def gen_receipt_and_invoice_file
    begin
      # Gen receipt voucher if not present
      event_company = event.sy_event_company
      unless receipt_voucher.present?
        ActiveRecord::Base.transaction do
          next_receipt_voucher_number = event_company.last_receipt_voucher_number + 1
          vouchers.build(voucher_number: ("%09d" % next_receipt_voucher_number)).save
          event_company.update_columns(last_receipt_voucher_number: next_receipt_voucher_number)
        end
      end

      # If not for next financial year
      unless invoice_voucher.present?
        # Gen invoice voucher if not present
        ActiveRecord::Base.transaction do
          next_invoice_voucher_number = event_company.last_invoice_voucher_number + 1
          vouchers.build(voucher_number: ("%09d" % next_invoice_voucher_number), voucher_type: Voucher.voucher_types[:invoice]).save
          event_company.update_columns(last_invoice_voucher_number: next_invoice_voucher_number)
        end
      end unless event.next_financial_year

      self.update_columns(sy_event_company_id: sy_event_company.id) unless sy_event_company_id == event_company.id

      self.sy_event_company.reload

      self.reload

      voucher_data = generate_invoice_data
      receipt_file_name = "receipt-voucher-#{receipt_voucher.voucher_number}-#{event_order.reg_ref_number}-#{id}.pdf"
      receipt_file = generate_pdf(:pdf, voucher_data, 'invoices/receipt_voucher.html.erb')
      receipt = Hash[file_name: receipt_file_name, file: receipt_file]
      data = [receipt]

      unless event.next_financial_year?
        invoice_file_name = "invoice-voucher-#{invoice_voucher.voucher_number}-#{event_order.reg_ref_number}-#{id}.pdf"
        invoice_file = generate_pdf(:pdf, voucher_data, 'invoices/invoice_voucher.html.erb')
        invoice = Hash[file_name: invoice_file_name, file: invoice_file]
        data << invoice
      end
      data
    rescue Exception => e
      data = []
      logger.info("Error ocuured while generating vouchers: #{e.message}, method: gen_receipt_invoice_file")
    end
    data
  end

  def gen_refund_voucher
    event_company = event.sy_event_company
    unless refund_voucher.present?

      next_refund_voucher_number = event_company.last_refund_voucher_number + 1

      vouchers.build(voucher_number: ("%06d" % next_refund_voucher_number), voucher_type: Voucher.voucher_types[:refund]).save!

      event_company.update_columns(last_refund_voucher_number: next_refund_voucher_number)

    end
    self.sy_event_company.reload

    self.reload

    # Refund Voucher
    payment_refund = payment_refund_line_item.try(:payment_refund)

    gateways = []

    refund_txns = payment_refund.event_order.transaction_logs.refund.select{|transaction_log| transaction_log.other_detail['payment_refund_id'] == payment_refund.id }

    if refund_txns.any?
      gateways = TransferredEventOrder.gateways.select{|g| refund_txns.collect(&:gateway_name).include?(g[:symbol]) }
    else
      payment_methods = payment_refund.event_order.transaction_logs.refund.last(1).collect{|transaction_log| transaction_log.other_detail['method'] }
      gateways = TransferredEventOrder.gateways.select{|g| payment_methods.include?(g[:payment_method]) }
    end

    mode_of_refund = gateways.collect{|g| g[:gateway_type] == 'online' ? 'Online' : g[:payment_method] }.collect(&:titleize).uniq.join('-')

    invoice = {}
    invoice[:refundable_amount] = payment_refund.try(:max_refundable_amount).to_f
    invoice[:receipt_voucher_number] = receipt_voucher_number
    invoice[:cancellation_charges] = event.cancellation_charges_by_policy([payment_refund_line_item.event_order_line_item_id])
    invoice[:cancellation_charges] = 0.0 if downgraded? || shivir_changed?

    invoice[:refunded_amount] = invoice[:refundable_amount] - invoice[:cancellation_charges]
    invoice[:mode_of_refund] = (invoice[:refunded_amount] > 0.0) ? mode_of_refund : '-'

    file_name = "refund-voucher-#{refund_voucher.voucher_number}-#{event_order.reg_ref_number}-#{id}.pdf"

    voucher_data = generate_invoice_data.merge(invoice).with_indifferent_access

    blob = generate_pdf(:pdf, voucher_data, 'invoices/refund_voucher.html.erb')

    if sy_event_company.try(:automatic_invoice)
      # Email Invoice only
      recipients = [sadhak_profile.try(:email), event_order.guest_email].extract_valid_emails
      attachments = {}
      # attachments[receipt.file_name] = receipt.file
      attachments[file_name] = blob
      from = GetSenderEmail.call(event)
      subject_suffix = event.get_clp_detail[:is_clp_event] ? "forum #{sadhak_profile.try(:active_forum_name).try(:titleize)}" : "event #{event.try(:event_name).try(:titleize)}"
      ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Registration Refund for #{subject_suffix} - #{event_order.reg_ref_number}", template: '', attachments: attachments).deliver if recipients.size.nonzero?
    end
    # Upload Receipt and Invoice

    Attachment.upload_file(file_name: file_name, content: blob, is_secure: false, bucket_name: ENV['ATTACHMENT_BUCKET'], attachable_id: refund_voucher.id, attachable_type: refund_voucher.class.to_s, file_type: 'application/pdf', prefix: "#{ENV['ENVIRONMENT']}/registration_vouchers/#{event_id}/#{event_order.reg_ref_number}")
  end

  def generate_vouchers
    # If transfered Event registration no invoice will be generated
    is_transfered = EventOrderLineItem.where(transferred_ref_number: event_order.reg_ref_number)
    return if is_transfered.present?

    begin
      # Get voucher data
      receipt, invoice = gen_receipt_and_invoice_file
      if sy_event_company.try(:automatic_invoice)
        # Email Invoice only
        receipents = [sadhak_profile.try(:email), event_order.guest_email].extract_valid_emails
        attachments = {}
        # attachments[receipt.file_name] = receipt.file
        if event.next_financial_year?
          attachments[receipt.file_name] = receipt.file
        else
          attachments[invoice.file_name] = invoice.file
        end
        from = GetSenderEmail.call(event)
        subject_suffix = event.get_clp_detail[:is_clp_event] ? "forum #{sadhak_profile.try(:active_forum_name).try(:titleize)}" : "event #{event.try(:event_name).try(:titleize)}"
        ApplicationMailer.send_email(from: from, recipients: receipents, subject: "Registration #{event.next_financial_year? ? 'Receipt' : 'Invoice'} for #{subject_suffix} - #{event_order.reg_ref_number}", template: '', attachments: attachments).deliver if receipents.size.nonzero?
      end
      uploading_data =  event.next_financial_year? ? [receipt] : [receipt, invoice]

      # Upload Receipt and Invoice
      uploading_data.each do |voucher_file|
        current_voucher = voucher_file.file_name.include?('receipt')? receipt_voucher : invoice_voucher
        Attachment.upload_file(file_name: voucher_file.file_name, content: voucher_file.file, is_secure: false, bucket_name: ENV['ATTACHMENT_BUCKET'], attachable_id: current_voucher.id, attachable_type: current_voucher.class.to_s, file_type: 'application/pdf', prefix: "#{ENV['ENVIRONMENT']}/registration_vouchers/#{event_id}/#{event_order.reg_ref_number}")
        # File.delete(voucher.file) if File.exist?(voucher.file)
      end
      if event.next_financial_year?
        time = ((event.event_end_date.to_time - Time.now).to_i/3600) + 7
        delay(run_at: time.hours.from_now).generate_invoice
      end

    rescue Exception => e
      logger.info("Error occured in generate vouchers: #{e.message}")
    end
    errors.empty?
  end

  def generate_invoice
    # Generate invoice
    begin
      # Get voucher data
      invoice = gen_invoice_file

      if sy_event_company.try(:automatic_invoice)
        # Email Invoice only
        receipents = [sadhak_profile.try(:email), event_order.guest_email].extract_valid_emails
        attachments = {}
        attachments[invoice.file_name] = invoice.file
        from = GetSenderEmail.call(event)
        subject_suffix = event.get_clp_detail[:is_clp_event] ? "forum #{sadhak_profile.try(:active_forum_name).try(:titleize)}" : "event #{event.try(:event_name).try(:titleize)}"
        ApplicationMailer.send_email(from: from, recipients: receipents, subject: "Registration Invoice for #{subject_suffix} - #{event_order.reg_ref_number}", template: '', attachments: attachments).deliver if receipents.size.nonzero?
      end

      uploading_data = [invoice]

      # Upload Invoice
      uploading_data.each do |voucher_file|
        current_voucher = invoice_voucher
        Attachment.upload_file(file_name: voucher_file.file_name, content: voucher_file.file, is_secure: false, bucket_name: ENV['ATTACHMENT_BUCKET'], attachable_id: current_voucher.id, attachable_type: current_voucher.class.to_s, file_type: 'application/pdf', prefix: "#{ENV['ENVIRONMENT']}/registration_vouchers/#{event_id}/#{event_order.reg_ref_number}")
      end
    rescue Exception => e
      logger.info("Error occured in generate vouchers: #{e.message}")
    end
  end

  def gen_invoice_file
    begin
      event_company = event.sy_event_company

      # Gen invoice voucher if not present
      unless invoice_voucher.present?
        next_invoice_voucher_number = event_company.last_invoice_voucher_number + 1

        vouchers.build(voucher_number: ("%06d" % next_invoice_voucher_number), voucher_type: Voucher.voucher_types[:invoice]).save!

        event_company.update_columns(last_invoice_voucher_number: next_invoice_voucher_number)
      end

      self.sy_event_company.reload

      self.reload

      voucher_data = generate_invoice_data

      invoice_file_name = "invoice-voucher-#{invoice_voucher.voucher_number}-#{event_order.reg_ref_number}-#{id}.pdf"
      invoice_file = generate_pdf(:pdf, voucher_data, 'invoices/invoice_voucher.html.erb')
      invoice = Hash[file_name: invoice_file_name, file: invoice_file]
      data = invoice
    rescue Exception => e
      data = nil
      logger.info("Error ocuured while generating vouchers: #{e.message}, method: gen_invoice_file")
    end
    return data
  end

  handle_asynchronously :generate_vouchers
  handle_asynchronously :gen_refund_voucher

  def generate_sewa_profile_report(line_items, event)

    # Generate header .
    header = ["S.NO", "SYID", "FIRST_NAME", "LAST_NAME", "MOBILE", "EMAIL", "REGISTRATION_NUMBER", "REG_REF_NUMBER", "VOLUNTARY_ORGANISATION", "SEVA_PREFERENCE", "EXPERTISE", "AVAILABILTY"]

    # Hold generated rows
    rows = []

    # Iterate over event registrations with status [nil, updated]
    (line_items || []).each_with_index do |item, index|

      begin

        sadhak_profile = item.sadhak_profile

        seva_preference = item.sadhak_profile.try(:sadhak_seva_preference)

        # Hold single row
        row = []

        # Push data according to header
        row.push(index+1)

        row.push(sadhak_profile.try(:syid))

        row.push(sadhak_profile.try(:first_name))

        row.push(sadhak_profile.try(:last_name))

        row.push(sadhak_profile.try(:mobile))

        row.push(sadhak_profile.try(:email))

        if event.sy_event_company_id.present?
          row.push(item.try(:event_registration).try(:serial_number).present? ? item.event_registration.serial_number.to_i + 100 : "NA")
        else
          row.push(item.try(:registration_number))
        end

        row.push(item.try(:event_order).try(:reg_ref_number))

        row.push(seva_preference.try(:voluntary_organisation))

        row.push(seva_preference.try(:seva_preference))

        row.push(seva_preference.try(:expertise))

        row.push(seva_preference.try(:availability))

        rows.push(row)

      rescue Exception => e
        logger.info("Exception occured at EventRegistration model method: generate_sewa_profile_report: error: #{e.message}, details: item: #{item.try(:inspect)}, sadhak_profile: #{sadhak_profile.try(:inspect)}, seva_preference: #{seva_preference.try(:inspect)}")
        raise e.message
      end
    end
    return {header: header, rows: rows}
  end

  def self.valid_registration_statuses
    return (EventRegistration.statuses.slice('success', 'updated', 'cancelled_refund_pending', 'upgraded', 'downgraded', 'name_changed', 'downgrade_requested', 'shivir_change_requested', 'name_change_requested', 'upgrade_requested').values + [nil])
  end

  # Method to do form registration for forum app changes.
  def perform_forum_registration
    begin
      order = self.event_order
      club_member = SyClubMember.new(sy_club_id: order.try(:sy_club_id), guest_email: order.try(:guest_email), transaction_id: order.try(:transaction_id), payment_method: order.try(:payment_method), event_registration_id: self.id, status: SyClubMember.statuses['approve'], sadhak_profile_id: self.sadhak_profile_id, club_joining_date: self.created_at)
      logger.info("EventRegistration: perform_forum_registration, SyClubMember errors: #{club_member.errors.full_messages}") unless club_member.save
      club_member.remove_pendings("Removing members that are found in pending status against event order: #{order.id}")
    rescue Exception => e
      logger.info("Something went wrong in method: perform_forum_registration, error: #{e.message}")
      Rollbar.error(e)
    end
    true
  end

  def renew_registration_status
    begin
      registration = EventRegistration.where(event_id: self.event_id, status: EventRegistration.valid_registration_statuses, sadhak_profile_id: self.sadhak_profile_id).last

      member = registration.try(:sy_club_member)

      if registration.present?

        remaining_days = registration.get_remaining_days

        if remaining_days > 0
          # Mark event registration and member as renewed.
          registration.update_columns(status: EventRegistration.statuses['renewed'])
          registration.event_order_line_item.update_columns(status: EventOrderLineItem.statuses['renewed'])
          member.update_columns(status: SyClubMember.statuses['renewed']) if member.present?
        end

        self.expires_at = (get_expiry_days.to_i + remaining_days.to_i)

        self.renewed_from = registration.id

      else

        self.expires_at = get_expiry_days.to_i

      end

    rescue => e
      logger.info("Something went wrong in method: get_old_registration_details, error: #{e.message}")
      Rollbar.error(e)
    end
  end

  # method to get remaining get of expiration
  def get_remaining_days
    ((self.created_at.to_date + self.expires_at.to_i) - Date.today).to_i
  end

  # method to get expiry days of registration
  def get_expiry_days
    india_event_ids = GlobalPreference.get_value_of('india_clp_events').to_s.split(',')
    global_event_ids = GlobalPreference.get_value_of('global_clp_events').to_s.split(',')
    if india_event_ids.include?(self.event_id.to_s)
      exp_days_count = GlobalPreference.get_value_of('india_clp_validity')
    elsif global_event_ids.include?(self.event_id.to_s)
      exp_days_count = GlobalPreference.get_value_of('global_clp_validity')
    end
    exp_days_count
  end

  def do_generate_file(event_type_id, from, to, recipients)
    begin
      sadhak_profile_ids = EventRegistration.joins(:event).where(event_registrations: {status: EventRegistration.valid_registration_statuses}, events: {event_type_id: event_type_id}).where('event_registrations.created_at >= ? AND event_registrations.created_at <= ?', from, to).pluck(:sadhak_profile_id)

      raise 'Sadhak profiles not found with selected creterion.' if sadhak_profile_ids.size == 0

      sadhak_profiles = SadhakProfile.where(id: sadhak_profile_ids).includes({ address: [:db_city, :db_state, :db_country] }).order(:id)

      # Generate profiles data.
      file = GenerateExcel.generate(GenerateSadhakProfilesExcel.call(sadhak_profiles, nil))

      if recipients.present?
        ApplicationMailer.send_email(recipients: recipients, subject: "Sadhak List - #{DateTime.now.strftime('%F %T')}-#{DateTime.now.to_i}.", attachments: Hash["sadhak_list_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", file]).deliver
      else
        file
      end

    rescue => e
      if recipients.present?
        ApplicationMailer.send_email(recipients: recipients, subject: "Error: Generate sadhak list  - Dated: #{DateTime.now.strftime('%F %T')}-#{DateTime.now.to_i}", template: 'notify_exception', text: e.message).deliver
      else
        raise e.message
      end
    end
  end

  def expiration_date
    m_validity = ''
    if self.event_order.sy_club_id.present?
      m_validity = "#{(self.created_at.to_date + self.expires_at.to_i - 1).strftime('%b %d, %Y')}"
    end
    m_validity
  end

  def cancel_forum_membership
    begin
      member = self.sy_club_member
      member.update(status: SyClubMember.statuses.cancelled) if member.present?
    rescue => e
      Rollbar.error(e)
    end
    errors.empty?
  end

  def self.event_registration_report_rows(event, from = nil, to = nil)
    # Assign default value to from and to
    from = from.present? ? from : (Date.today - 10.years).to_s
    to = to.present? ? to : (Date.today + 10.years).to_s

    # Get demand draft details if payment made by demand draft
    is_clp_event = event.get_clp_detail[:is_clp_event]

    # Hold registration centers
    registration_centers = {}

    header = event_registration_report_header(event)

    row = []

    event.event_registrations.where(status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)).where('created_at >= ? AND created_at <= ?', from, to).find_each(batch_size: 1).with_index do |_registration, _index|
      begin

        # Hold single row
        row = []

        # Get sadhak profile
        sadhak_profile = _registration.sadhak_profile
        _registration_version = _registration.versions.last.try(:reify)
        old_sadhak_profile = _registration_version.try(:sadhak_profile)
        is_syid_changed = (old_sadhak_profile.present? and sadhak_profile.id != old_sadhak_profile.id)

        # Get sadhak profile address
        sadhak_address = sadhak_profile.try(:address)

        # Get event order associated to current registration
        event_order = _registration.event_order

        event_order_version = nil
        if _registration.status == 'upgraded'
          (event_order.try(:versions) || []).reverse.each do |eov|
            if eov.reify.diff(event_order)[:transaction_id].present?
              event_order_version = eov.reify
              break
            end
          end
        else
          event_order_version = event_order.try(:versions).try(:last).try(:reify)
        end

        is_transaction_id_changed = (event_order_version.present? and event_order.try(:transaction_id) != event_order_version.transaction_id)

        # Get registred seating category assosciation
        seating_category_association = _registration.event_seating_category_association
        old_seating_category_association = _registration_version.try(:event_seating_category_association)
        is_category_changed = (old_seating_category_association.present? and seating_category_association.try(:id) != old_seating_category_association.try(:id))

        # Get registred seating category
        seating_category = _registration.seating_category
        old_seating_category = old_seating_category_association.try(:seating_category)

        # Get event order line item
        event_order_line_item = _registration.event_order_line_item
        event_order_line_item_version = event_order_line_item.try(:versions).try(:last).try(:reify)

        # Push serial number that will 100 plus if company attached else registration number
        # REGISTRATION_NUMBER/S.NO
        row.push(if event.sy_event_company_id.present? then
                     _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : 'NA'
                else
                  event_order_line_item.try(:registration_number).present? ? event_order_line_item.registration_number : 'NA'
                end)

        # Push data according to header
        # OLD_SYID
        row.push(is_syid_changed ? old_sadhak_profile.try(:syid) : nil)

        # OLD_FIRST_NAME
        row.push(is_syid_changed ? old_sadhak_profile.try(:first_name) : nil)

        # OLD_LAST_NAME
        row.push(is_syid_changed ? old_sadhak_profile.try(:last_name) : nil)

        # NEW_SYID/SYID
        row.push(sadhak_profile.try(:syid))

        # NEW_FIRST_NAME/FIRST_NAME
        row.push(sadhak_profile.try(:first_name))

        # NEW_LAST_NAME/LAST_NAME
        row.push(sadhak_profile.try(:last_name))

        # NEW_GENDER
        row.push(sadhak_profile.try(:gender))

        # NEW_DATE_OF_BIRTH
        row.push(sadhak_profile.try(:date_of_birth).try(:strftime, '%b %d %Y'))

        # NAME_CHANGED_DATE
        row.push(is_syid_changed ? _registration_version.try(:version).try(:created_at).to_s : nil)

        # NEW_MOBILE
        row.push(sadhak_profile.try(:mobile))

        # NEW_EMAIL
        row.push(sadhak_profile.try(:email))

        # To check whether masking is applicable or not
        # NEW_COUNTRY
        row.push(sadhak_address.try(:country_name))

        # NEW_STATE
        row.push(sadhak_address.try(:state_name))

        # NEW_CITY
        row.push(sadhak_address.try(:city_name))

        # NEW_STREET_ADDRESS
        row.push(sadhak_address.try(:street_address))

        # OLD_TRANSACTION_ID
        row.push(is_transaction_id_changed ? event_order_version.try(:transaction_id) : nil)

        # NEW_TRANSACTION_ID/TRANSACTION_ID
        row.push(event_order.try(:transaction_id))

        # DATE_OF_TRANSACTION
        row.push(event_order_version.try(:version).try(:created_at).to_s)

        # OLD_SEATING_CATEGORY
        row.push(is_category_changed ? old_seating_category.try(:category_name) : nil)

        # NEW_SEATING_CATEGORY/SEATING_CATEGORY
        row.push(seating_category.try(:category_name))

        # OLD_CATEGORY_AMOUNT
        row.push(is_category_changed ? ('%.2f' % old_seating_category_association.try(:price).to_f) : nil)

        # NEW_CATEGORY_AMOUNT/CATEGORY_AMOUNT
        row.push('%.2f' % seating_category_association.try(:price).to_f)

        # OLD_DISCOUNT
        row.push(event_order_line_item_version.present? ? ('%.2f' % event_order_line_item_version.try(:discount).to_f) : nil)

        # NEW_DISCOUNT/DISCOUNT
        row.push('%.2f' % event_order_line_item.try(:discount).to_f)

        # DIFFERENCE_AMOUNT(PAID/REFUNDED)
        amount_diff = is_category_changed ? (old_seating_category_association.try(:price).to_f - seating_category_association.try(:price).to_f): nil
        paid_or_refunded = if amount_diff.present? then
                              if amount_diff < 0 then
                                ' - PAID'
                              else
                                amount_diff > 0 ? ' - REFUNDED' : nil
                              end
                            else
                              nil
                            end
        row.push(paid_or_refunded.present? ? (('%.2f' % amount_diff.to_f.abs) + paid_or_refunded) : nil)

        total_tax_detail = (event_order_line_item.try(:total_tax_detail) || {}).deep_symbolize_keys

        # TOTAL_TAX
        row.push('%.2f' % total_tax_detail[:total_tax_paid].to_f)

        # CONVIENENCE_CHARGES
        row.push('%.2f' % total_tax_detail[:total_convenience_charges].to_f)

        # TOTAL_PAID
        row.push('%.2f' % (seating_category_association.try(:price).to_f - event_order_line_item.try(:discount).to_f + total_tax_detail[:total_tax_paid].to_f + total_tax_detail[:total_convenience_charges].to_f))

        # REGISTRATION_STATUS
        row.push(_registration.status.present? ? EventOrder.template_status_mapper[_registration.status.to_s] : 'Success')

        row.push(event_order.try(:reg_ref_number))

        row.push(_registration.try(:created_at).try(:to_s))

        row.push(event.try(:event_name))

        row.push(event.try(:event_start_date).try(:to_s))

        row.push(event.try(:event_end_date).try(:to_s))

        row.push(event_order.try(:status))

        row.push(event_order.try(:payment_method))

        # Push registration id and item id for debugging purpose
        row.push(_registration.id)
        row.push(event_order_line_item.try(:id))

        if is_clp_event
          # FORUM_ID
          row.push(_registration.sy_club_member.try(:sy_club_id))

          # FORUM_NAME
          row.push(_registration.sy_club_member.try(:sy_club).try(:name))
        end

        # If event is doctor's event
        if event.event_type.name == 'Doctors Event'.downcase

          # MEDICAL_DEGREE
          medical_practitioners_profile = sadhak_profile.try(:medical_practitioners_profile)
          row.push(medical_practitioners_profile.try(:medical_degree))

          # CURRENT_PROFESSION
          row.push(medical_practitioners_profile.try(:current_professional_role))

          # WORK_ENVIRONMENT
          row.push(medical_practitioners_profile.try(:work_enviroment))

          # SPECIALITY_AREA
          medical_practitioner_speciality_area = medical_practitioners_profile.try(:medical_practitioner_speciality_area)
          row.push(medical_practitioner_speciality_area.present? ? medical_practitioner_speciality_area.try(:name) : medical_practitioners_profile.try(:other_speciality))
        end

        # if Payment made usning demand draft
        if event_order.payment_method == 'Demand draft'

          # Details for specific payment of demand draft
          dd_data = PgSyddTransaction.where(event_order_id: _registration.event_order_id).last

          row.push(dd_data.try(:bank_name)) rescue 'NA'

          row.push(dd_data.try(:additional_details)) rescue 'NA'

          row.push(dd_data.try(:dd_date).to_s) rescue 'NA'

          # Increase efficency to find registration center - Start

          registration_center = nil

          if event_order.user_id.present?
            # Load registration center details form object
            registration_center = registration_centers["#{_registration.event_id}-#{event_order.user_id}"]

            # if not found then load from database and keep a copy of it
            unless registration_center.present?

              event_order.registration_center_user_id = _registration.event.get_registration_center_user_id(event_order.user_id)

              registration_center = event_order.registration_center

              registration_centers["#{_registration.event_id}-#{event_order.user_id}"] = registration_center if registration_center.present?

            end
          end

          # Increase efficency to find registration center - End

          row.push(event_order.try(:user).try(:sadhak_profile).try(:syid).to_s + '-' + registration_center.try(:name).to_s) rescue 'NA'
        end

        # Category logic
        category_index = header.index(seating_category.try(:category_name).try(:upcase))
        row[category_index] = 1 if category_index.present?

        GC.start if (_index + 1) % 1000 == 0

        _registration = sadhak_profile = _registration_version = old_sadhak_profile = is_syid_changed = sadhak_address = event_order = event_order_version = is_transaction_id_changed = seating_category_association = old_seating_category_association = is_category_changed = seating_category = old_seating_category = event_order_line_item = event_order_line_item_version = amount_diff = paid_or_refunded = total_tax_detail = medical_practitioners_profile = medical_practitioner_speciality_area = dd_data = registration_center = category_index = _index = nil

        yield row

      rescue Exception
        yield []
      end
    end
  end

  def mark_expired
    if status && sy_club_member && !sy_club_member.renewed? && !renewed?
      days = ((created_at.to_date + expires_at.to_i) - Date.today).to_i
      if days <= 0
        self.update_columns(status: EventRegistration.statuses['expired']) unless expired?
        sy_club_member.update_columns(status: SyClubMember.statuses['expired']) unless sy_club_member.expired?
      end
    end
  end

  def self.event_registration_report_header(event)

    # Get demand draft details if payment made by demand draft
    currency = event.pay_in_usd? ? 'USD' : event.try(:address).try(:db_country).try(:currency_code)

    # Generate common header for doctor's + regular event.
    header = %W(REGISTRATION_NUMBER OLD_SYID OLD_FIRST_NAME OLD_LAST_NAME NEW_SYID NEW_FIRST_NAME NEW_LAST_NAME NEW_GENDER NEW_DATE_OF_BIRTH NAME_CHANGED_DATE NEW_MOBILE NEW_EMAIL NEW_COUNTRY NEW_STATE NEW_CITY NEW_STREET_ADDRESS OLD_TRANSACTION_ID NEW_TRANSACTION_ID DATE_OF_TRANSACTION OLD_SEATING_CATEGORY NEW_SEATING_CATEGORY OLD_CATEGORY_AMOUNT(#{currency}) NEW_CATEGORY_AMOUNT(#{currency}) OLD_DISCOUNT(#{currency}) NEW_DISCOUNT(#{currency}) DIFFERENCE_AMOUNT(PAID/REFUNDED) TOTAL_TAX(#{currency}) CONVIENENCE_CHARGES(#{currency}) TOTAL_PAID(#{currency}) REGISTRATION_STATUS REG_REF_NUMBER REGISTRATION_DATE EVENT_NAME EVENT_START_DATE EVENT_END_DATE PAYMENT_STATUS PAYMENT_METHOD REGISTRATION_ID ITEM_ID)

    # Add column forum name and forum id if event is clp event
    if event.get_clp_detail[:is_clp_event]
      header += %w(FORUM_ID FORUM_NAME)
    end

    # Add doctor's header if event is doctor's event
    if event.event_type.name == 'Doctors Event'.downcase
      header += %w(MEDICAL_DEGREE CURRENT_PROFESSION WORK_ENVIRONMENT SPECIALITY_AREA)
    end

    # Add demand draft details if payment made by demand draft
    if event.event_orders.where(payment_method: 'Demand draft').exists?
      header += %w(BANK_NAME ADMIN_NOTES DD_DATE REGISTERED_BY)
    end

    # Add event categories name
    header += event.seating_categories.pluck(:category_name).map(&:upcase)

    header

  end

  def self.event_registration_report_rows_test(event, _times)

    header = event_registration_report_header(event)

    index = 0

    (_times || 10000).to_i.times do

      yield Array.new(header.size) { SecureRandom.uuid }

      index += 1

    end

  end

  def broadcast_seats_available
    old_seating_category = EventSeatingCategoryAssociation.find_by_id(event_seating_category_association_id_before_last_save)
    ActionCable.server.broadcast('seats_available',
    {
      old_event_seating_category_association_id: old_seating_category.try(:id),
      old_seating_capacity: old_seating_category.try(:seats_available),
      new_event_seating_category_association_id: event_seating_category_association_id,
      new_seating_capacity: event_seating_category_association.try(:seats_available)
    })
  end


  def generate_vouchers_without_pdf
    # If transfered Event registration no invoice will be generated
    is_transfered = EventOrderLineItem.where(transferred_ref_number: event_order.reg_ref_number)
    return if is_transfered.present?

    begin
      # Get voucher data

      event_company = event.sy_event_company

      next_receipt_voucher_number = event_company.last_receipt_voucher_number + 1
      vouchers.build(voucher_number: ("%09d" % next_receipt_voucher_number.to_i)).save
      event_company.update_columns(last_receipt_voucher_number: next_receipt_voucher_number)

      unless event.next_financial_year
        next_invoice_voucher_number = event_company.last_invoice_voucher_number + 1

        vouchers.build(voucher_number: ("%09d" % next_invoice_voucher_number.to_i), voucher_type: Voucher.voucher_types[:invoice]).save!

        event_company.update_columns(last_invoice_voucher_number: next_invoice_voucher_number)
      end

      if event.next_financial_year && event.event_end_date <= Time.now
        next_invoice_voucher_number = event_company.last_invoice_voucher_number + 1

        vouchers.build(voucher_number: ("%09d" % next_invoice_voucher_number.to_i), voucher_type: Voucher.voucher_types[:invoice]).save!

        event_company.update_columns(last_invoice_voucher_number: next_invoice_voucher_number)
      end

      self.update_columns(sy_event_company_id: sy_event_company.id) unless sy_event_company_id == event_company.id

      self.reload

      if event.next_financial_year? && event.event_end_date > Time.now
        time = ((event.event_end_date.to_time - Time.now).to_i/3600)
        delay(run_at: time.hours.from_now).generate_invoice
      end

    rescue Exception => e
      logger.info("Error occured in generate vouchers: #{e.message}")
    end
  end

  def generate_member_excel(expired_regs, type, opts = [])

    # Generate header .
    header = %w(SNO SYID FIRST_NAME LAST_NAME EMAIL MOBILE COUNTRY STATE CITY PROFESSION FORUM_NAME FORUM_ID FORUM_MEMBERSHIP_EXPIRATION_DATE)

    opts.each do |opt|
      header.push(opt[:header_name]) if opt[:header_name].present? and opt[:proc].kind_of?(Proc)
    end

    # Hold generated rows
    rows = []
    # Iterate over event registrations with status [nil, updated]
    expired_regs.each_with_index do |expired_reg, index|
      # Hold single row
      sadhak_profile = expired_reg.sadhak_profile
      sadhak_address = sadhak_profile.address
      sy_club_member = expired_reg.sy_club_member

      row = []

      # Push data according to header
      row << (index+1)

      row << sadhak_profile.try(:syid)

      row << sadhak_profile.try(:first_name)

      row << sadhak_profile.try(:last_name)

      row << sadhak_profile.try(:email)

      row << sadhak_profile.try(:mobile)

      row << sadhak_address.try(:country_name)

      row << sadhak_address.try(:state_name)

      row << sadhak_address.try(:city_name)

      row << sadhak_address.try(:street_address)

      row << sadhak_profile.try(:professional_detail).try(:profession).try(:name)

      row << sy_club_member.sy_club.name.try(:titleize)

      row << sy_club_member.sy_club.id

      row << expired_reg.try(:expiration_date)

      opts.each do |opt|
        row.push(opt[:proc].call(sy_club_member)) if opt[:header_name].present? and opt[:proc].kind_of?(Proc)
      end
      rows.push(row)
    end
    return {header: header, rows: rows}
  end

  private

  def generate_vouchers_if_status_changed
    # Generate receipt and invoice

    # If upgradation happen, Invoice will be generated
    generate_vouchers if upgraded?

    # If any refund happen
    # if downgraded? || name_changed? || shivir_changed? || cancelled_refunded?
    #   gen_refund_voucher if payment_refund_line_item.try(:payment_refund).present?
    # end
  end

  def gen_voucher_prefix_if_not_in_company(voucher_type)
    voucher = voucher_type
    if event.get_clp_detail[:is_clp_event]
      # Forum
      voucher_prefix = voucher.eql?("invoice") ? "FM/" : 'RV/FM/DEL/'
    elsif event.graced_by == 'Subtle presence of Babaji'
      # Live or Online Shivir
      voucher_prefix = voucher.eql?("invoice") ? "LS/" : (voucher.eql?("receipt") ? 'RV/LS/DEL/' : 'RFV/LS/DEL/')
      voucher_prefix = voucher.eql?("invoice") ? "LSH/" : (voucher.eql?("receipt") ? 'RV/LSH/DEL/' : 'RFV/LSH/DEL/') if sy_event_company.is_shiv_yog_herbs_llp?
    else
      # Main Shivir
      code = STATE_WITH_INVOICE_CODE[sy_event_company.try(:address).try(:state_name).to_s.try(:titleize)].try(:[], :code) || 'DL'
      voucher_prefix = voucher.eql?("invoice") ? "MS/" : (voucher.eql?("receipt") ? "RV/MS/#{code}/" : "RFV/MS/#{code}/")
      voucher_prefix = voucher.eql?("invoice") ? "MSH/" : (voucher.eql?("receipt") ? "RV/MSH/#{code}/" : "RFV/MSH/#{code}/") if sy_event_company.is_shiv_yog_herbs_llp?
    end
    voucher_prefix
  end

end
