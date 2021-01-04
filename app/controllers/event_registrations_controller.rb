class EventRegistrationsController < ApplicationController
  include EventRegistrationsHelper
  before_action :set_event_registration, only: [:show, :edit, :update, :destroy, :event_registration_detail, :generate_voucher]

  # GET /event_registrations
  def index
    @event_registrations = EventRegistration.all
  end

  # GET /event_registrations/1
  def show
  end

  # GET /event_registrations/new
  def new
    @event_registration = EventRegistration.new
  end

  # GET /event_registrations/1/edit
  def edit
  end

  # POST /event_registrations
  def create
    @event_registration = EventRegistration.new(event_registration_params)

    if @event_registration.save
      redirect_to @event_registration, notice: 'Event registration was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /event_registrations/1
  def update
    if @event_registration.update(event_registration_params)
      redirect_to @event_registration, notice: 'Event registration was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /event_registrations/1
  def destroy
    @event_registration.destroy
    redirect_to event_registrations_url, notice: 'Event registration was successfully destroyed.'
  end

  def registration_detail
    @event_registration = EventRegistration.find(params[:event_registration_id])
  end

  def generate_csv
    begin

      # Find event
      event = Event.find_by_id(params[:event_id])
      raise SyException, 'Please select a valid event.' unless event.present?
      raise SyException, 'Please provide a valid file format.' unless %w(csv excel).include?(params[:format])
      raise SyException, "Shivir: #{event.try(:event_name)} does not have any registrations." if event.event_registrations.count == 0

      (Date.strptime(params[:from], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid from date.' if params[:from].present?
      (Date.strptime(params[:to], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid to date.' if params[:to].present?

      params[:format] = params[:format] == 'excel' ? 'xls' : params[:format]

      event_registration = event.event_registrations.last

      # Authorize operation
      raise 'You are not authorize to perform this action.' unless EventRegistrationPolicy.new(current_user, event_registration).generate_csv?

      recipients = params[:email].try(:split, ',').try(:extract_valid_emails).try(:uniq)

      if recipients.present?
        event_registration.delay.process_report_generate(params.slice(:event_id, :format, :download, :from, :to).merge({send_email: true, recipients: recipients, user_id: current_user.try(:id)}))
      else
        blob = event_registration.process_report_generate(params.slice(:event_id, :email, :format, :from, :to).merge({download: true, user_id: current_user.try(:id)}))
      end

    rescue Exception => e
      is_error = true
      message = e.message
    end

    unless is_error
      if recipients.present?
        flash[:notice] = "Soon you will get an email on #{recipients.to_sentence}."
        redirect_back(fallback_location: proc { root_path })
      else
        send_data blob, :filename => "#{event.event_name}_registrations_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.#{params[:format]}"
      end
    else
      flash[:alert] = message
      redirect_back(fallback_location: proc { root_path })
    end
  end

  # method to generate seva sadhak excel
  def generate_sewa_report
    begin

      event_registration = EventRegistration.new

      event = Event.find_by_id(params[:event_id])

      raise SyException, "Please select a valid event." unless event.present?

      line_item_ids = event.event_registrations.pluck(:event_order_line_item_id)

      raise SyException, "No registration found." unless line_item_ids.present?

      line_items = EventOrderLineItem.includes({sadhak_profile: [:sadhak_seva_preference]}, :event_order, :event_registration).where(id: line_item_ids, available_for_seva: true)

      raise SyException, "No registration found." unless line_items.present?

      data = event_registration.generate_sewa_profile_report(line_items, event)

      if data.present? and data[:rows].count > 0
        blob = GenerateExcel.generate(data)
      end

    rescue => e
      is_error = true
      message = e.message
    end

    unless is_error
      send_data blob, :filename => "#{event.try(:event_name_with_location)}_seva_profile_list_#{event.id}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.xls"
    else
      flash[:alert] = message
      redirect_back(fallback_location: proc { root_path })
    end

  end

  def event_registration_detail

    authorize @event_registration

    @syid = @event_registration.sadhak_profile.syid
    @full_name = @event_registration.sadhak_profile.full_name
    @reg_ref_number = @event_registration.event_order.reg_ref_number
    @transaction_id = @event_registration.event_order.transaction_id
    @payment_method = @event_registration.event_order.payment_method
    @status = @event_registration.status.try(:titleize)
    @registration_date = @event_registration.created_at.try(:strftime, '%b %d, %Y')
    @registration_time = @event_registration.created_at.try(:strftime, '%I:%M:%S %p')
    @is_transfered = EventOrderLineItem.where(transferred_ref_number: @reg_ref_number).present?

    respond_to do |format|
      format.js {}
    end

  end

  def ready_event_orders
    event_registration = EventRegistration.last

    # Iterate over ready events only
    Event.where(status: Event.statuses.slice(:test_registration, :ready).values).each do |event|
      begin

        next if event.event_end_date + 1 < Date.today
        # Hold seating category seats details
        seating_category_details = []

        # Calculate seating category data
        event.event_seating_category_associations.each do |sc|
          seating_category_details.push({
            total_seats: sc.try(:seating_capacity),
            seats_occupied: event.event_registrations.where(event_seating_category_association_id: sc.id, status: EventOrderLineItem.valid_line_item_statuses).count,
            extra_seats: event.event_registrations.where(event_seating_category_association_id: sc.id, is_extra_seat: true, status: EventOrderLineItem.valid_line_item_statuses).count,
            category_name: sc.try(:seating_category).try(:category_name)
          })
        end

        # Recieptients
        recipients = event.registrations_recipients.try(:send, :split, ",")

        # Generate data for excel
        blob = event_registration.do_generate_event_registration_file(event, false, false, "xls")

        if recipients.present? and recipients.extract_valid_emails.count > 0

          # Extract valid emails
          recipients = recipients.extract_valid_emails

          # Reciepitents changed according to environment
          recipients = ['prince@metadesignsolutions.in'] if Rails.env == "development"

          # Generate excel file
          # blob = event_registration.generate_excel_file(data)

          # File name
          file_name = "#{event.try(:event_name_with_location)}_registrations_#{event.id}_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"
          attachments = Hash[file_name, blob]

          # Send email
          from = GetSenderEmail.call(event)
          ApplicationMailer.send_email(from: from, recipients: recipients, template: 'send_daily_email', subject: "#{event.try(:event_name_with_location)} registrations list and seating categories details - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", attachments: attachments, seating_category_details: seating_category_details, event: event).deliver
        end

      # Rescue from exceptions
      rescue SyException => e
        logger.info("Manula Exception: #{e.message}")
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
      end
    end
  end

  def generate_voucher
    # Already generated voucher -> raise exception
    begin
      raise SyException, "invalid request" unless @event_registration.event.is_in_india?
      @event_registration.generate_vouchers
      flash[:success] = "Process has been initiated. File will available soon for download."
    rescue SyException => e
      flash[:error] = e.message
    end
    redirect_back(fallback_location: proc { root_path })
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_registration
      @event_registration = EventRegistration.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_registration_params
      params[:event_registration].permit!
    end
end
