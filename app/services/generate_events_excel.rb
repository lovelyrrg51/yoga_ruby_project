# frozen_string_literal: true

class GenerateEventsExcel
  DATE_FORMAT = '%b %d, %Y'

  def self.call events
    header = %w(EVENT_ID EVENT_NAME EVENT_START_DATE EVENT_START_TIME EVENT_END_DATE EVENT_END_TIME CREATOR CREATED_AT UPDATED_AT GRACED_BY CONTACT_DETAILS VIDEO_URL STATUS EVENT_TYPE PAYMENT_CATEGORY TOTAL_CAPACITY CONTACT_EMAIL WEBSITE ADDITIONAL_DETAILS PHOTO_PROOF_REQUIRED SHOW_SEATS_AVAILABILTY EVENT_LOCATION PRE_APPROVAL_REQUIRED REGISTRATION_RECIPIENTS SHOW_SHIVIR_PRICE FULL_PROFILE_NEEDED PAY_IN_USD DISCOUNT_PLAN EVENT_COMPANY CANCELLATION_PLAN AUTOMATIC_REFUND HAS_SEVA_PREFERENCE APPROVER_EMAIL LOGISTIC_EMAIL END_DATE_IGNORED TOTAL_REGISTRATIONS STREET_ADDRESS COUNTRY STATE CITY)

    # Add tax types in header
    TaxType.all.order(:id).each do |tt|
      header.push("#{tt.name.upcase} (%)")
    end

    # Add seating category details
    SeatingCategory.all.order(:id).each do |sc|
      sc_name = sc.category_name.try(:upcase)
      header.push(sc_name)
      header.push("#{sc_name} PRICE")
      header.push("#{sc_name} CAPACITY")
    end

    rows = []

    events.each do |event|
      row = []

      # EVENT_ID
      row.push(event.id)

      # EVENT_NAME
      row.push(event.event_name)

      # EVENT_START_DATE
      row.push(event.event_start_date.try(:strftime, DATE_FORMAT))

      # EVENT_START_TIME
      row.push(event.event_start_time)

      # EVENT_END_DATE
      row.push(event.event_end_date.try(:strftime, DATE_FORMAT))

      # EVENT_END_TIME
      row.push(event.event_end_time)

      # CREATOR
      creator_sp = event.creator_user.try(:sadhak_profile)
      row.push("#{creator_sp.try(:syid)}-#{creator_sp.try(:full_name)}")

      # CREATED_AT
      row.push(event.created_at.strftime(DATE_FORMAT))

      # UPDATED_AT
      row.push(event.updated_at.strftime(DATE_FORMAT))

      # GRACED_BY
      row.push(event.graced_by)

      # CONTACT_DETAILS
      row.push(event.contact_details)

      # VIDEO_URL
      row.push(event.video_url)

      # STATUS
      row.push(event.status.try(:humanize))

      # EVENT_TYPE
      row.push(event.event_type.try(:name))

      # PAYMENT_CATEGORY
      row.push(event.payment_category.try(:humanize))

      # TOTAL_CAPACITY
      row.push(event.total_capacity)

      # CONTACT_EMAIL
      row.push(event.contact_email)

      # WEBSITE
      row.push(event.website)

      # ADDITIONAL_DETAILS
      row.push(event.additional_details)

      # PHOTO_PROOF_REQUIRED
      row.push(event.is_photo_proof_required)

      # SHOW_SEATS_AVAILABILTY
      row.push(event.show_seats_availability)

      # EVENT_LOCATION
      row.push(event.event_location)

      # PRE_APPROVAL_REQUIRED
      row.push(event.pre_approval_required)

      # REGISTRATION_RECIPIENTS
      row.push(event.registrations_recipients)

      # SHOW_SHIVIR_PRICE
      row.push(event.show_shivir_price)

      # FULL_PROFILE_NEEDED
      row.push(event.full_profile_needed)

      # PAY_IN_USD
      row.push(event.pay_in_usd)

      # DISCOUNT_PLAN
      row.push(event.discount_plan.try(:name))

      # EVENT_COMPANY
      row.push(event.sy_event_company.try(:name))

      # CANCELLATION_PLAN
      row.push(event.event_cancellation_plan.try(:name))

      # AUTOMATIC_REFUND
      row.push(event.automatic_refund)

      # HAS_SEVA_PREFERENCE
      row.push(event.has_seva_preference)

      # APPROVER_EMAIL
      row.push(event.approver_email)

      # LOGISTIC_EMAIL
      row.push(event.logistic_email)

      # END_DATE_IGNORED
      row.push(event.end_date_ignored)

      # TOTOAL_REGISTRATIONS
      row.push(event.valid_event_registrations.count)

      # ADDRESS_DETAIL
      address = event.address

      # STREET_ADDRESS
      row.push(address.try(:street_address))

      # COUNTRY
      row.push(address.try(:country_name))

      # STATE
      row.push(address.try(:state_name))

      # CITY
      row.push(address.try(:city_name))

      # TAX_TYPE_DETAILS
      event.event_tax_type_associations.each do |etta|
        row[header.index("#{etta.tax_type_name.try(:upcase)} (%)")] = etta.percent if header.index("#{etta.tax_type_name.try(:upcase)} (%)").present?
      end

      # SEATING CATEGORY DETAILS
      event.event_seating_category_associations.each do |esca|
        sc_name = esca.category_name
        row[header.index(sc_name)] = 'TRUE' if header.index(sc_name).present?
        row[header.index("#{sc_name} PRICE")] = ('%.2f' % esca.price.to_f) if header.index("#{sc_name} PRICE").present?
        row[header.index("#{sc_name} CAPACITY")] = esca.seating_capacity if header.index("#{sc_name} CAPACITY").present?
      end

      rows.push(row)
    end

    { header: header, rows: rows }
  end

end
