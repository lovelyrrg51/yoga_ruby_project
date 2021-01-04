module Api::V1
  class EventRegistrationsController < BaseController
    include ActionController::Live

    before_action :authenticate_user!, except: [:ready_event_orders]
    before_action :set_event_registration, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:ready_event_orders]
    respond_to :json

    # GET /event_registrations
    def index
      # @event_registrations = policy_scope(EventRegistration)
      render json: @event_registrations, serializer: PaginationSerializer
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
        render json: @event_registration
      else
        render json: @event_registration.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /event_registrations/1
    def update
      if @event_registration.update(event_registration_params)
        render json: @event_registration
      else
        render json: @event_registration.errors, status: :unprocessable_entity
      end
    end

    # DELETE /event_registrations/1
    def destroy
      aa = @event_registration.destroy
      render json: aa
    end

    def count
      event_registrations_count = EventRegistration.where(event_id: params[:event_id], status: EventRegistration.valid_registration_statuses).count
      render json: {count: event_registrations_count}
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
          event_registrations_count = EventRegistration.where(event_id: event.id, status: (EventRegistration.valid_registration_statuses + EventRegistration.statuses.slice('cancelled', 'cancelled_refunded').values)).count

          raise SyException, 'We are not able to process your request for such large data. Please use email option.' if event_registrations_count > REGISTRATION_REPORT_LIMIT

          blob = event_registration.process_report_generate(params.slice(:event_id, :email, :format, :from, :to).merge({download: true, user_id: current_user.try(:id)}))
        end

      rescue SyException => e
        is_error = true
        message = e.message
        logger.info("Manual Exception: #{message}")
      rescue Exception => e
        is_error = true
        message = e.message
        logger.info(e.backtrace.inspect)
        logger.info("Runtime Exception: #{message}")
      end

      # Return json
      unless is_error
        if recipients.present?
          render file: 'customs/success.html.erb', :locals => {title: '', message: "Soon you will get an email on #{recipients.to_sentence}." }
        else
          send_data blob, :filename => "#{event.event_name}_registrations_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.#{params[:format]}"
        end
      else
        render file: 'customs/422.html.erb', :locals => {title: 'Event Registration Report Download Error.', message: message }
      end
    end

    def generate_csv_direct_stream
      begin

        # Find event
        @event = Event.find_by_id(params[:event_id])
        raise SyException, 'Please select a valid event.' unless @event.present?
        raise SyException, 'Please provide a valid file format.' unless %w(csv excel).include?(params[:format])
        raise SyException, "Shivir: #{@event.try(:event_name)} does not have any registrations." if @event.event_registrations.count == 0

        (Date.strptime(params[:from], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid from date.' if params[:from].present?
        (Date.strptime(params[:to], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid to date.' if params[:to].present?

        params[:format] = params[:format] == 'excel' ? 'xls' : params[:format]

        event_registration = @event.event_registrations.last

        # Authorize operation
        raise 'You are not authorize to perform this action.' unless EventRegistrationPolicy.new(current_user, event_registration).generate_csv?

      rescue Exception => e
        is_error = true
        message = e.message
      end

      unless is_error

        respond_to do |format|

          file_name = "#{@event.event_name.to_s.parameterize}-registrations"

          if params[:format] == 'xls'

            format.excel { stream_xls_report(file_name, params[:format]) }

          else

            format.csv { stream_csv_report(file_name, params[:format]) }

          end

        end

      else
        render file: 'customs/422.html.erb', :locals => {title: 'Event Registration Report Download Error.', message: message }
      end
    end

    def generate_csv_test
      begin

        # Find event
        @event = Event.find_by_id(params[:event_id])
        raise SyException, 'Please select a valid event.' unless @event.present?
        raise SyException, 'Please provide a valid file format.' unless %w(csv excel).include?(params[:format])
        raise SyException, "Shivir: #{@event.try(:event_name)} does not have any registrations." if @event.event_registrations.count == 0

        (Date.strptime(params[:from], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid from date.' if params[:from].present?
        (Date.strptime(params[:to], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid to date.' if params[:to].present?

        params[:format] = params[:format] == 'excel' ? 'xls' : params[:format]

        event_registration = @event.event_registrations.last

        # Authorize operation
        raise 'You are not authorize to perform this action.' unless EventRegistrationPolicy.new(current_user, event_registration).generate_csv?

      rescue Exception => e
        is_error = true
        message = e.message
      end

      unless is_error

        respond_to do |format|

          file_name = "#{@event.event_name.to_s.parameterize}-registrations"

          if params[:format] == 'xls'

            format.excel do

              stream_file(file_name, params[:format]) do |stream|

                stream.write CustomXls.header

                stream.write CustomXls::Row.new(EventRegistration.event_registration_report_header(@event)).to_xml

                EventRegistration.event_registration_report_rows_test(@event, params[:times]) do |row|

                  stream.write CustomXls::Row.new(row).to_xml

                  row = nil

                end

                stream.write CustomXls.footer

              end

            end

          else

            format.csv do

              stream_file(file_name, params[:format]) do |stream|

                stream.write "#{EventRegistration.event_registration_report_header(@event).join(', ')}\n"

                EventRegistration.event_registration_report_rows_test(@event, params[:times]) do |row|

                  stream.write "#{row.join(', ')}\n"

                  row = nil

                end

              end

            end

          end

        end

      else
        render file: 'customs/422.html.erb', :locals => {title: 'Event Registration Report Download Error.', message: message }
      end
    end

    def generate_csv_with_stream
      begin

        # Find event
        event = Event.find_by_id(params[:event_id])

        raise SyException, 'Please select a valid event.' unless event.present?

        raise SyException, 'Please provide a valid file format.' unless %w(csv excel).include?(params[:format])

        raise SyException, "Shivir: #{event.try(:event_name)} does not have any registrations." if event.event_registrations.count == 0

        (Date.strptime(params[:from], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid from date.' if params[:from].present?

        (Date.strptime(params[:to], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid to date.' if params[:to].present?

        params[:format] = params[:format] == 'excel' ? 'xlsx' : params[:format]

        event_registration = event.event_registrations.last

        # Authorize operation
        raise 'You are not authorize to perform this action.' unless current_user.present? && current_user.super_admin?

        delayed_job_progress = DelayedJobProgress.create!

        Delayed::Job.enqueue EventRegistrationsExcelReport.new(params.slice(:event_id, :format, :from, :to).merge({delayed_job_progress: delayed_job_progress}))

      rescue Exception => e

        message = e.message

      end

      if message.present?

        render json: {errors: [message]}, status: :unprocessable_entity

      else

        render json: {job_id: delayed_job_progress.try(:id)}

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
      render json: 'success'.to_json
    end

    def locate_collection
      @event_registrations = EventRegistrationPolicy::Scope.new(current_user, EventRegistration).resolve(filtering_params).page(params[:page]).per(params[:per_page]).includes(EventRegistration.includable_data)
    end

    def error(message = 'error', key = 'error')
      errorObj = {errors:{}}
      errorObj[:errors][key.to_s] = message
      render json:  errorObj, status: :unprocessable_entity
    end

    def success(data = {}, message = 'success', key = 'success')
      successObj = {success:{}}
      successObj[:success][key.to_s] = message
      successObj[:success]['data'] = data
      render json: successObj
    end

    def invoice
      event = Reports::EventSummaryReports.globdal_summary
      if @event
        render json: "success"
      else
        render json: "Failure"
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

      rescue SyException => e
        is_error = true
        message = e.message
        logger.info("Manual Exception: #{message}")
      rescue Exception => e
        is_error = true
        message = e.message
        logger.info("Runtime Exception: #{message}")
        logger.info e.backtrace
      end

      unless is_error
        send_data blob, :filename => "#{event.try(:event_name_with_location)}_seva_profile_list_#{event.id}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.xls"
      else
        render json: {error: [message]}, status: :unprocessable_entity
      end

    end

    def generate_file
      begin
        event_registration = EventRegistration.last

        # Authorize request
        raise SyException, 'You are not authrized.' unless EventRegistrationPolicy.new(current_user, event_registration).generate_file?

        raise SyException, 'SadhakProfile missing for logged in user' unless current_user.sadhak_profile.present?

        event_type_id = EventType.find_by_name("#{params[:event_type]}").try(:id) || EventType.find_by_id("#{params[:event_type]}").try(:id)

        raise SyException, 'Please input a valid event type.' unless event_type_id.present?

        recipients = params[:recipients].try(:split, ',').try(:extract_valid_emails).try(:uniq)

        # Check for from and to date
        (Date.strptime(params[:from], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid from date.' if params[:from].present?
        (Date.strptime(params[:to], '%Y-%m-%d').present? rescue false) or raise SyException, 'Please select a valid to date.' if params[:to].present?

        from = params[:from] || (Date.today - 10.years).to_s

        to = params[:to] || (Date.today + 10.years).to_s

        if recipients.present?
          recipients = ['prince@metadesignsolution.in'] if ENV['ENVIRONMENT'] == 'development'

          recipients = %w(victor.sen@metadesignsolutions.com.au prince@metadesignsolution.in) if ENV['ENVIRONMENT'] == 'testing'

          event_registration.delay.do_generate_file(event_type_id, from, to, recipients)
        else
          blob = event_registration.do_generate_file(event_type_id, from, to, recipients)
        end

      rescue SyException => e
        is_error = true
        message = e.message
      rescue Exception => e
        is_error = true
        message = e.message
      end

      unless is_error
        if recipients.present?
          render file: 'customs/success.html.erb', :locals => {title: '', message: "Soon you will get an email on #{recipients.to_sentence}." }
        else
          send_data blob, :filename => "sadhak_list_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"
        end
      else
        render file: 'customs/422.html.erb', :locals => {title: 'Sadhak List Download Error.', message: message }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_event_registration
      @event_registration = EventRegistration.preloaded_data.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_registration_params
      params.require(:event_registration).permit(:EventRegistration)
    end

    def filtering_params
      params.slice(:event_id, :first_name, :payment_method, :reg_ref_number, :transaction_id, :status)
    end

    def stream_csv_report(file_name, format)

      stream_file(file_name, format) do |stream|

        stream.write "#{EventRegistration.event_registration_report_header(@event).join(', ')}\n"

        EventRegistration.event_registration_report_rows(@event, params[:from], params[:to]) do |row|

          stream.write "#{row.join(', ')}\n"

          row = nil

        end

      end

    end

    def stream_xls_report(file_name, format)

      stream_file(file_name, format) do |stream|

        stream.write CustomXls.header

        stream.write CustomXls::Row.new(EventRegistration.event_registration_report_header(@event)).to_xml

        EventRegistration.event_registration_report_rows(@event, params[:from], params[:to]) do |row|

          stream.write CustomXls::Row.new(row).to_xml

          row = nil

        end

        stream.write CustomXls.footer

      end

    end

  end
end
