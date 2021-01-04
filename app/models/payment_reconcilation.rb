class PaymentReconcilation < ApplicationRecord
  include AASM

  FILE_TYPE = { original: 0, valid: 1, invalid: 2 }

  belongs_to :event, optional: true
  has_many :attachments, as: :attachable
  accepts_nested_attributes_for :attachments, :allow_destroy => true

  before_create :assign_reconcilation_ref_number

  scope :file_name, ->(file_name) { where("file_name ILIKE ?", "%#{file_name.to_s.strip}%") }
  scope :status, ->(status) { where(status: status) }
  scope :upload_date, ->(upload_date) { where('DATE(created_at) = ?', upload_date) }

  enum status: { initiated: 0, processing: 1, completed: 2, failed: 3 }

  aasm column: :status, enum: true do
    state :initiated, initial: true
    state :processing
    state :completed

    event :processing do
      transitions from: :initiated, to: :processing
    end

    event :completed do
      transitions from: [:processing], to: :completed
    end

    event :failed do
      transitions from: [:processing], to: :failed
    end

  end

  # method to upload payment reconcilation file
  def self.proceed_for_reconcilation_upload(params)

    # Raise error is file or method is missing
    raise SyException.new("File is missing. Please upload a file.") unless (params.has_key?('file') and params[:file].present?)
    raise SyException.new("Please input a valid method.") unless params[:method].present?

    # validate file extension
    raise SyException.new("Unknown file type: #{params[:file].original_filename}") unless ['.csv', '.xls', '.xlsx'].include?(File.extname(params[:file].original_filename))

    # validate file extension
    raise SyException.new("No data in given file: #{params[:file].original_filename}") unless (params[:file]).size > 0

    # To create entry in database
    payment_reconcilation = self.new(user_id: $current_user.id , method: params[:method])
    raise SyException.new(payment_reconcilation.errors.full_message.first) unless payment_reconcilation.save

    # Compute file name and file extension for this upload
    file = params[:file]
    params[:original_filename] = "#{File.basename(params[:file].original_filename, File.extname(params[:file].original_filename))}-#{payment_reconcilation.reconcilation_ref_number}"
    params[:file_ext] = File.extname(file.original_filename)

    payment_reconcilation.update_columns(file_name: params[:original_filename])

    # Attach rails environment prefix
    params[:prefix] = "#{ENV["ENVIRONMENT"]}/reconcilation/#{params[:method]}"

    # Upload the original file to S3

    attachment = Attachment.upload_file(file_name: "#{params[:original_filename]}-original#{params[:file_ext]}", file_path: file.path, content: file, is_secure: true, bucket_name: params[:bucket_name], attachable_id: payment_reconcilation.id, attachable_type: payment_reconcilation.class.to_s, file_type: file.content_type, prefix: params[:prefix])
    # call delay job
    # payment_reconcilation.reconcilation_job(prefix: params[:prefix])

    ## for Delay job
    payment_reconcilation.delay(run_at: 1.minutes.from_now).reconcilation_job(prefix: params[:prefix])

    # Return result
    return payment_reconcilation
  end

  def reconcilation_job(options = {})
    begin
      @options = options

      # changes object status
      self.update_columns(status: 1)

      # find original file and read the file
      orignal_att = self.attachments.find{|att| att.name.include?("#{self.reconcilation_ref_number}-original")}

      s3_file = Aws::S3::Bucket.new(orignal_att.s3_bucket).object(orignal_att.s3_path)

      url = s3_file.presigned_url(:get, secure: true, expires_in: 7200).to_s

      @file = open(url)

      # read the file by using validate file type method
      @file_object = validate_file(@file, orignal_att.name)

      raise SyException.new("All rows are blank in file. Please input some data for processin") if @file_object[:content].count == 0

      # Call method to update databse entries on behalf of reconcilation file
      self.send("#{self.method}_reconcilation")

    rescue SyException => e
      logger.info("Manual Exception: #{e.message}")
      message = e.message
    rescue Exception => e
      logger.info("Runtime Exception: #{e.message}")
      logger.info(e.backtrace.inspect)
      message = e.message
    end
    if message.present?
      self.update_columns(status: 3, message: message)
    else
      self.update_columns(status: 2)
    end
  end

  def validate_file(file, file_name)
    case File.extname(file_name)
    when '.csv'
      return read_csv(file.path)
    when '.xls'
      return read_xls(file.path)
    when '.xlsx'
      return read_xlsx(file.path)
    else
      raise SyException.new("Unknown file type: #{file_name}")
    end
  end

  # method to perforn ccavenue reconcilation
  def ccavenue_reconcilation

    # to validate header
    raise SyException.new('Please input valid column headers: [ccavenue ref#, order no, order status, merchant param3]') unless (@file_object[:header].include?('ccavenue ref#') and @file_object[:header].include?('order no') and @file_object[:header].include?('order status') and @file_object[:header].include?('merchant param3'))

    valid_registrations = []
    invalid_registrations = []
    shipped_items = @file_object[:content].select{|e| e['order status'.to_sym] == 'Shipped'}

    # Raise exception in case of old order number
    shipped_items.each do |si|
      raise SyException, 'File contains old enteries that cannot be processed.' unless si['order no'.to_sym].include?('-')
    end

    # below ref number and order ids fetching will work only for new registration,as previously we was using different order number format
    reg_ref_numbers = shipped_items.collect{|e| e['order no'.to_sym].split('-')[1]}
    event_orders = EventOrder.where(reg_ref_number: reg_ref_numbers).includes({event_order_line_items: [:sadhak_profile]}, :event, :transaction_logs, :order_payment_informations)

    # Perform databse updation for successfull payments
    ApplicationRecord.transaction do
      (shipped_items || []).each_with_index do |e, index|
        # CCavenue reference number
        ccavenue_tracking_id = e['ccavenue ref#'.to_sym]

        Rails.logger.info("Processing row: #{index+1} - Inside shipped_items: #{e}")

        # get and update event order  details
        event_order = event_orders.find{|eo| eo.reg_ref_number == e['order no'.to_sym].split('-')[1].to_s}

        Rails.logger.info("Processing row: #{index+1} - Event order id: #{event_order.try(:id)}, Reg ref number: #{event_order.try(:reg_ref_number)}")

        next unless event_order.present?

        Rails.logger.info("Processing row: #{index+1} - Event order status: #{event_order.try(:status)}")

        if event_order.status == 'pending' or event_order.status == 'approve'

          is_all_valid = true

          old_syids = []

          (event_order.sadhak_profiles || []).each do |profile|

            # to check whether sadhak profile already registered for this event
            if profile.events.include?(event_order.event) and not (profile.renewal_events || []).include?(event_order.event)
              old_syids.push(profile.syid)
              is_all_valid &&= false
            end
          end

          invalid_registrations.push(ccavenue_tracking_id: ccavenue_tracking_id, profile: old_syids, ref_number: event_order.reg_ref_number, affected_profiles: (event_order.sadhak_profile_ids - old_syids.map{|e| e[/-?\d+/].to_i}), message: "SYIDS: #{old_syids} already registered for the event: #{event_order.event.try(:event_name)}. So cannot update this application.") unless is_all_valid

          Rails.logger.info("Processing row: #{index+1} - is_all_valid: #{is_all_valid}")

          if is_all_valid

            order_payment_information = event_order.order_payment_informations.find { |order| order.id.to_s == e['order no'.to_sym].split('-')[2] }

            Rails.logger.info("Processing row: #{index+1} order_payment_information_id: #{order_payment_information.try(:id)} - order_payment_information status: #{order_payment_information.try(:status)}")

            _log = TransactionLog.find_by_id(e['merchant param3'.to_sym])

            Rails.logger.info("Processing row: #{index+1} - transaction_log: #{_log.try(:inspect)}")

            details = (_log.try(:request_params) || {}).deep_symbolize_keys[:details]

            Rails.logger.info("Processing row: #{index+1} - details: #{details}")

            event_order.update(status: 'success', transaction_id: e['ccavenue ref#'.to_sym], payment_method: 'Ccavenue Payment')

            Rails.logger.info("Processing row: #{index+1} - Event order status: #{event_order.try(:status)}")

            event_order = event_order.reload

            valid_registrations += event_order.event_registration_ids

            # update ccavenue order details
            order_payment_information.update(status: 'success', ccavenue_tracking_id: e['ccavenue ref#'.to_sym]) unless order_payment_information.nil? and order_payment_information.status != 'success'

             Rails.logger.info("Processing row: #{index+1} - Order payment information status: #{order_payment_information.try(:status)}")

            event_order.perform_updation(details) if details.present?

            if _log.present? and event_order.status == 'success'
              _log.update_columns(status: 1, gateway_response_object: e)
            end
          end
        end
      end
    end

    # generate excel file for newly created registrations
    if valid_registrations.size > 0
      generate_valid_registration_excel(valid_registrations)
    end

    if invalid_registrations.size > 0
      generate_invalid_registration_excel(invalid_registrations)
    end
  end

  #method to generate reconcilation registration excel
  def generate_valid_registration_excel(registrations)

    registrations = EventRegistration.where(id: registrations).includes({sadhak_profile: [{ address: [:db_city, :db_state, :db_country] }]}, :event_order, :event_order_line_item, :event_seating_category_association, :seating_category, :event, :sy_club_member)

    # Generate common header for doctor's + regular event.
      header = %w(REGISTRATION_NUMBER EVENT_ID SYID FIRST_NAME LAST_NAME MOBILE EMAIL COUNTRY STATE CITY STREET_ADDRESS TRANSACTION_ID SEATING_CATEGORY CATEGORY_AMOUNT REG_REF_NUMBER REGISTRATION_DATE EVENT_NAME EVENT_START_DATE EVENT_END_DATE PAYMENT_STATUS PAYMENT_METHOD FORUM_ID FORUM_NAME REGISTRATION_ID ITEM_ID)

    # Hold generated rows
    rows = []

    (registrations.sort_by{|i| i.event_id} || []).each_with_index do |_registration, _index|
      begin

        # Hold single row
        row = []

        # Get sadhak profile
        sadhak_profile = _registration.sadhak_profile

        # Get sadhak profile address
        sadhak_address = sadhak_profile.try(:address)

        # Get event order associated to current registration
        event_order = _registration.event_order

        # Get registred seating category assosciation
        seating_category_association = _registration.event_seating_category_association

        # Get registred seating category
        seating_category = _registration.seating_category

        # Get event order line item
        event_order_line_item = _registration.event_order_line_item

        # Push serial number that will 100 plus if company attached else registration number
        row.push(if _registration.event.sy_event_company_id.present? then
                   _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : 'NA'
                 else
                  _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : 'NA'
                  # Deprecated on sandeep ji request
                   # event_order_line_item.try(:registration_number).present? ? event_order_line_item.registration_number : 'NA'
                 end)

        # Push data according to header
        row.push(_registration.event_id)

        row.push(sadhak_profile.try(:syid))

        row.push(sadhak_profile.try(:first_name))

        row.push(sadhak_profile.try(:last_name))

        row.push(sadhak_profile.try(:mobile))

        row.push(sadhak_profile.try(:email))

        row.push(sadhak_address.try(:country_name))

        row.push(sadhak_address.try(:state_name))

        row.push(sadhak_address.try(:city_name))

        row.push(sadhak_address.try(:street_address))

        row.push(event_order.try(:transaction_id))

        row.push(seating_category.try(:category_name))

        row.push('%.2f' % seating_category_association.try(:price).to_f)

        row.push(event_order.try(:reg_ref_number))

        row.push(_registration.try(:created_at).try(:to_s))

        row.push(_registration.event.try(:event_name))

        row.push(_registration.event.try(:event_start_date).try(:to_s))

        row.push(_registration.event.try(:event_end_date).try(:to_s))

        row.push(event_order.try(:status))

        row.push(event_order.try(:payment_method))

        row.push(_registration.try(:sy_club_member).try(:sy_club_id))

        row.push(_registration.try(:sy_club_member).try(:sy_club).try(:name))

        # Push registration id and item id for debugging purpose
        row.push(_registration.id)

        row.push(event_order_line_item.try(:id))

        # Push single row to array
        rows.push(row)
      rescue Exception => e
        logger.info("EventRegistration #do_generate_event_registration_file: error: #{e.message} at #{_index} with event_registration id: #{_registration.try(:id)}")
        raise e.message
      end
    end

    # Upload valid absent list to S3
    generate_and_upload_registration_file(rows: rows, header: header, data_type: 'file', file_name: "#{self.file_name}-valid_registrations.xls", attachable_type: 'PaymentReconcilation', attachable_id: self.id, bucket_name: ENV['ATTACHMENT_BUCKET'], prefix: @options[:prefix]) if rows.count > 0
  end

  def generate_and_upload_registration_file(options = {})
    # Upload valid absent list to S3
    file = GenerateExcel.generate(rows: options[:rows], header: options[:header], data_type: options[:data_type])

    # Upload file to s3
    attachment = Attachment.upload_file({file_name: options[:file_name], file_path: file.path, content: file.path, is_secure: true, bucket_name: options[:bucket_name], attachable_id: options[:attachable_id], attachable_type: options[:attachable_type], file_type: "application/vnd.ms-excel", prefix: options[:prefix]})

    # Remove temp file
    begin
      file.close(true)
    rescue Exception => e
      logger.info(e.backtrace)
    end

    return true
  end

# To get file url according to file type
  def get_url(type)
    attachment = self.attachments.find{|att| att.name.include?("#{self.reconcilation_ref_number}-#{type}")}
    if attachment.present?
      s3_file = Aws::S3::Bucket.new(attachment.s3_bucket).object(attachment.s3_path)
      url = s3_file.presigned_url(:get, secure: true, expires_in: 7200).to_s
      @file = open(url)
    else
      @file = open("https://s3.amazonaws.com/syportalattachments/sample_files/ccavenue_reconcilation_with_no_data.xls")
    end
      return @file
  end

  def generate_invalid_registration_excel(inv_registrations)
    # Generate common header for doctor's + regular event.
      header = ["CCAVENUE_TRACKING_ID", "ALREADY_REGISTERED_SYID", "REG_REF_NUMBER", "AFFECTED_PROFILE_IDS", "REASON"]

    # Hold generated rows
    rows = []

    (inv_registrations || []).each do |invalid_reg, _index|
      begin

        # Hold single row
        row = []

        # Add ccavenue_tracking_id
        row.push(invalid_reg.ccavenue_tracking_id)

        # Push data according to header
        row.push(invalid_reg.profile.join(","))

        row.push(invalid_reg.ref_number)

        row.push(invalid_reg.affected_profiles.map{|s| "SY#{s}"}.join(","))

        row.push(invalid_reg.message)

        # Push single row to array
        rows.push(row)

      rescue Exception => e
        logger.info("EventRegistration #do_generate_event_registration_file: error: #{e.message} at #{_index} with event_registration id: #{invalid_reg.try(:id)}")
        raise e.message
      end
    end

    # Upload valid absent list to S3
    generate_and_upload_registration_file(rows: rows, header: header, data_type: "file", file_name: "#{self.file_name}-invalid_registrations.xls", attachable_type: 'PaymentReconcilation', attachable_id: self.id, bucket_name: ENV["ATTACHMENT_BUCKET"], prefix: @options[:prefix]) if rows.count > 0
    # In progress
  end


  private

  def assign_reconcilation_ref_number
    self.reconcilation_ref_number = "reconcilation_" + SecureRandom.hex[0..10]
  end
end
