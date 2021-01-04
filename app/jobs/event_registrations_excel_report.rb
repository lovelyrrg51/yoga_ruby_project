class EventRegistrationsExcelReport < DelayedJobProgressBase

  def perform

    update_stage('Working....!!')

    @event = Event.find(options[:event_id])
    @format = options[:format]
    @from = options[:from]
    @to = options[:to]
    @tmp_dir = "#{Rails.root}/tmp"
    @output_dir = "#{@tmp_dir}/#{Random.new_seed.to_s}"
    @output_file = "#{@tmp_dir}/#{Random.new_seed.to_s}.zip"

    # Create folder in tmp to store files
    FileUtils::mkdir_p(@output_dir)

    begin
      
      do_generate_event_registration_file

      update_stage('Generating Download Link....!!')

      zf = ZipFileGenerator.new(@output_dir, @output_file)
      zf.write()

      # Assign result to delayed_job_progress
      update_progress_result({link: link_for(file: @output_file)})
    
    rescue => exception
      
      raise exception.message
    
    ensure
  
      File.delete(@output_file) if File.exists?(@output_file)

      FileUtils.rm_rf(@output_dir)
    
    end

  end

  private

  def time_taken_to_process_1_record

    0.2

  end

  def do_generate_event_registration_file

    # Assign default value to from and to
    @from = @from.present? ? @from : (Date.today - 10.years).to_s
    @to = @to.present? ? @to : (Date.today + 10.years).to_s

    # Get demand draft details if payment made by demand draft
    payment_methods = @event.event_orders.pluck(:payment_method)
    currency = @event.pay_in_usd? ? 'USD' : @event.try(:address).try(:db_country).try(:currency_code)

    # Generate common @header for doctor's + regular event.
    @header = %W(REGISTRATION_NUMBER OLD_SYID OLD_FIRST_NAME OLD_LAST_NAME NEW_SYID NEW_FIRST_NAME NEW_LAST_NAME NEW_GENDER NEW_DATE_OF_BIRTH NAME_CHANGED_DATE NEW_MOBILE NEW_EMAIL NEW_COUNTRY NEW_STATE NEW_CITY NEW_STREET_ADDRESS OLD_TRANSACTION_ID NEW_TRANSACTION_ID DATE_OF_TRANSACTION OLD_SEATING_CATEGORY NEW_SEATING_CATEGORY OLD_CATEGORY_AMOUNT(#{currency}) NEW_CATEGORY_AMOUNT(#{currency}) OLD_DISCOUNT(#{currency}) NEW_DISCOUNT(#{currency}) DIFFERENCE_AMOUNT(PAID/REFUNDED) TOTAL_TAX(#{currency}) CONVIENENCE_CHARGES(#{currency}) TOTAL_PAID(#{currency}) REGISTRATION_STATUS REG_REF_NUMBER REGISTRATION_DATE EVENT_NAME EVENT_START_DATE EVENT_END_DATE PAYMENT_STATUS PAYMENT_METHOD REGISTRATION_ID ITEM_ID IS_FORUM_MEMBER IS_FORUM_BOARD_MEMBER)

    # Add column forum name and forum id if event is clp event
    @is_clp_event = @event.get_clp_detail[:is_clp_event]
    if @is_clp_event
      @header += %w(FORUM_ID FORUM_NAME)
    end

    # Add doctor's @header if event is doctor's event
    if @event.event_type.name == 'Doctors Event'.downcase
      @header += %w(MEDICAL_DEGREE CURRENT_PROFESSION WORK_ENVIRONMENT SPECIALITY_AREA)
    end

    # Add demand draft details if payment made by demand draft
    if payment_methods.include?('Demand draft')
      @header += %w(BANK_NAME ADMIN_NOTES DD_DATE REGISTERED_BY)
    end

    # Add event categories name
    @header += @event.seating_categories.pluck(:category_name).map(&:upcase)

    # Hold registration centers
    @registration_centers = {}

    if @event.sy_event_company_id.present?
      @event_registrations = EventRegistration.where(event_id: @event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)).where('created_at >= ? AND created_at <= ?', @from, @to).order('serial_number')
    else
      @event_registrations = EventRegistration.where(event_id: @event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)).where('created_at >= ? AND created_at <= ?', @from, @to).order('event_order_line_item_id')
    end

    # Calculate step increment
    @total_event_registrations = @event_registrations.count

    @step_increment = @progress_max / @total_event_registrations.to_f

    add_run_time(@total_event_registrations * time_taken_to_process_1_record)

    generate_rows

    nil

  end

  def generate_rows

    @event_registrations.find_in_batches(batch_size: @batch_size).with_index do |registrations, group_index|

      rows = []

      registrations.each_with_index do |_registration, _index|

        rows << row(_registration)

        processed_event_registration = (group_index * @batch_size) + _index + 1

        remaining_time_string = seconds_to_hms(@total_event_registrations * time_taken_to_process_1_record - processed_event_registration * time_taken_to_process_1_record)

        update_stage_progress("#{processed_event_registration}/#{@total_event_registrations} - Remaining Time: #{remaining_time_string}", step: @step_increment)

      end

      f = send("generate_#{@format == 'xlsx' ? 'excel' : 'csv'}_file", header: @header, rows: rows, data_type: 'file')

      new_f_name = "Sheet#{group_index + 1}" + File.extname(f)  
      
      FileUtils.mv(f.path, "#{@output_dir}/#{new_f_name}")

      nil

    end

  end

  def row(_registration)

    # Hold single row
    row = []

    # Details for specific payment of demand draft
    @dd_data = PgSyddTransaction.where(event_order_id: _registration.event_order_id).last

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
    row.push(if @event.sy_event_company_id.present? then
                  _registration.try(:serial_number).present? ? (_registration.serial_number.to_i + 100) : 'NA'
                else
                  event_order_line_item.try(:registration_number).present? ? event_order_line_item.registration_number : 'NA'
                end)

    # Push data according to @header
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

    row.push(@event.try(:event_name))

    row.push(@event.try(:event_start_date).try(:to_s))

    row.push(@event.try(:event_end_date).try(:to_s))

    row.push(event_order.try(:status))

    row.push(event_order.try(:payment_method))

    # Push registration id and item id for debugging purpose
    row.push(_registration.id)
    row.push(event_order_line_item.try(:id))

    # IS_FORUM_MEMBER
    row.push(sadhak_profile.try(:active_club_ids).present? ? 'Yes' : 'No')

    # IS_FORUM_BOARD_MEMBER
    row.push(sadhak_profile.try(:sy_clubs).present? ? 'Yes' : 'No')

    if @is_clp_event
      # FORUM_ID
      row.push(_registration.sy_club_member.try(:sy_club_id))

      # FORUM_NAME
      row.push(_registration.sy_club_member.try(:sy_club).try(:name))
    end

    # If event is doctor's event
    if @event.event_type.name == 'Doctors Event'.downcase

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
    if event_order.try(:payment_method) == 'Demand draft'

      row.push(@dd_data.try(:bank_name)) rescue 'NA'

      row.push(@dd_data.try(:additional_details)) rescue 'NA'

      row.push(@dd_data.try(:dd_date).to_s) rescue 'NA'

      # Increase efficency to find registration center - Start

      registration_center = nil

      if event_order.user_id.present?
        # Load registration center details form object
        registration_center = @registration_centers["#{_registration.event_id}-#{event_order.user_id}"]

        # if not found then load from database and keep a copy of it
        unless registration_center.present?

          event_order.registration_center_user_id = _registration.event.get_registration_center_user_id(event_order.user_id)

          registration_center = event_order.registration_center

          @registration_centers["#{_registration.event_id}-#{event_order.user_id}"] = registration_center if registration_center.present?

        end
      end

      # Increase efficency to find registration center - End

      row.push(event_order.try(:user).try(:sadhak_profile).try(:syid).to_s + '-' + registration_center.try(:name).to_s) rescue 'NA'
    end

    # Category logic
    category_index = @header.index(seating_category.try(:category_name).try(:upcase))
    row[category_index] = 1 if category_index.present?

    row

  end

end
