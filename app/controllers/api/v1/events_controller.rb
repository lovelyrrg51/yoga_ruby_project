module Api::V1
  class EventsController < ApplicationController

    before_action :authenticate_user!, :except => [:index, :show, :events_excel, :list, :wp_event_meta_types, :wp_events, :paginated]
    before_action :locate_collection, :only => :index
    before_action :locate_paginated_collection, :only => :paginated
    skip_before_action :verify_authenticity_token, :only => [:create, :index, :show, :events_excel, :wp_event_meta_types, :wp_events]
    before_action :set_event, only: [:show, :edit, :update, :destroy, :replicate, :by_gender, :by_category, :by_mode_of_payment, :by_profession, :by_category_and_mode_of_payment, :payment_info, :payment_info_by_rc, :by_age_group, :by_previous_events_registered]

    # GET /events
    def index
      if params.has_key?("mode") and params[:mode] == "owned"
        own_event
      elsif params.has_key?("mode") and params[:mode] == "custom_data"
        render json: Event.includes(:event_type).all, each_serializer: EventBasicDetailSerializer
      elsif params.has_key?("mode") and params[:mode] == "club_events"
        render json: Event.where(is_club_event: true), each_serializer: EventBasicDetailSerializer
      else
        render json: @events, each_serializer: EventIndexSerializer
      end
    end

    def paginated
      if params.has_key?("mode") and params[:mode] == "owned"
        own_event_paginated
      elsif params.has_key?("mode") and params[:mode] == "custom_data"
        render json: @events, each_serializer: EventBasicDetailSerializer, serializer: PaginationSerializer
      elsif params.has_key?("mode") and params[:mode] == "club_events"
        @events = @events.select{ |e| e.is_club_event? }
        render json: @events, each_serializer: EventBasicDetailSerializer, serializer: PaginationSerializer
      else
        render json: @events, each_serializer: EventBasicDetailSerializer, serializer: PaginationSerializer
      end
    end

    def list
      limit = list_params[:limit] || 6
      graced_by = list_params[:graced_by] || 'Baba ji'
      today = Time.now.strftime('%Y-%m-%d')
      @events = Event.where('event_end_date > ? AND status = ? AND graced_by = ?', today, Event.statuses.ready, graced_by).limit(limit).includes(:event_type)
      render json: @events, each_serializer: EventBasicDetailSerializer
    end

    # GET /event_meta_types
    def wp_event_meta_types
      render json: {event_meta_types: %w(virtual mega live)}
    end

    # GET /wp/events
    def wp_events
      render json: Event.all, each_serializer: WpEventSerializer
    end

    # GET /events/1
    def show
      render json: @event
    end

    # GET /events/new
    def new
      @event = Event.new
    end

    # GET /events/1/edit
    def edit
    end

    # POST /events
    def create
      @event = Event.new(event_params)
      authorize @event
      @event.creator_user_id = current_user.id
      if @event.save!
        render json: @event
      else
        render json: @event.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /events/1
    def update
      authorize @event
      if @event.update(event_params)
        render json: @event
      else
        render json: @event.errors, status: :unprocessable_entity
      end
    end

    # DELETE /events/1
    def destroy
      aa = @event.destroy
      render json: aa
    end

    def bulk_upload
      begin
        event = Event.find_by_id(params[:attachable_id])
        raise SyException, "Please select a event." unless event.present?
        authorize event
        if params[:attachable_id].present? and params[:attachable_type].present? and params[:file].present?
          params[:method] = params[:attachable_type]
          params[:attachable_type] = "Event"
          params[:bucket_name] = ENV["ATTACHMENT_BUCKET"]
          params[:current_user_id] = current_user.try(:id)
          result = event.proceed_for_bulk_upload(params)
        else
          is_error = true
          result = "Parameters missing."
        end
      rescue AWS::Errors => e
        logger.info("S3 error occured: #{e.message}")
        is_error = true
        result = e.message
      rescue SyException => e
        is_error = true
        result = e.message
        Rails.logger.info("Manual exception: #{e.message}")
      rescue Exception => e
        is_error = true
        result = e.message
        Rails.logger.info("Runtime Exception: #{e.message}")
        Rails.logger.info(e.backtrace)
      end
      unless is_error
        # url = result.present? ? result.s3_downloadable_url(bucket_name: result.s3_bucket, s3_file_path: result.s3_path) : ""
        render json: {invalid_url: ""}
      else
        render json: {key: [result]}, status: :unprocessable_entity
      end
    end

    # POST /events/forum_event
    def forum_event
      begin
        # Find refernce event
        @re = Event.preloaded_data.find_by_id(event_params[:reference_event_id])
        raise SyException, "Please provide a refernce event." unless @re.present?

        # Authorize user
        authorize @re

        # Validate parameters
        raise SyException, "Please input shivir name." unless event_params[:event_name].present?
        raise SyException, "Please input event end time." unless event_params[:event_end_time].present?
        raise SyException, "Please input event end date." unless event_params[:event_end_date].present?
        raise SyException, "Please input event start date." unless event_params[:event_start_date].present?
        raise SyException, "Please input event start time." unless event_params[:event_start_time].present?
        raise SyException, "Please input contact details." unless event_params[:contact_details].present?
        raise SyException, "Please input contact email." unless event_params[:contact_email].present?
        raise SyException, "Please input event location." unless event_params[:event_location].present?
        raise SyException, "Please input total seating capacity." unless event_params[:total_capacity].present?
        raise SyException, "Please input registration reciepents." unless event_params[:registrations_recipients].present?

        # Shivir Name - event_name
        # Date and Time - event_end_time, event_end_date, event_start_date, event_start_time
        # Contact No. and Email - contact_details, contact_email
        # Display Location - event_location
        # Seating capacity (just one number, total capacity which would be copied to all categories) - total_capacity
        # Email recipients. - registrations_recipients

        ActiveRecord::Base.transaction do
          # Clone event params
          cloned_params = event_params.clone

          # Update values
          cloned_params[:is_club_event] = true
          cloned_params[:creator_user_id] = current_user.try(:id)
          cloned_params[:status] = Event.statuses["proposed"]

          # Create a new event from refernce event.
          @event = Event.new(@re.attributes.except('created_at','updated_at','id').deep_merge(cloned_params))
          raise SyException, @event.errors.full_messages.first unless @event.save

          # Clone reference event associations

          # Clone event tax type associations
          @re.event_tax_type_associations.each do |_association|
            association = @event.event_tax_type_associations.build(_association.attributes.except('created_at','updated_at','id'))
            raise SyException, association.errors.full_messages.first unless association.save
          end

          # Clone event seating category associations
          @re.event_seating_category_associations.each do |_association|
            association = @event.event_seating_category_associations.build(_association.attributes.except('created_at','updated_at','id').deep_merge({seating_capacity: event_params[:total_capacity]}))
            raise SyException, association.errors.full_messages.first unless association.save
          end

          # Clone address
          address = @event.build_address(@re.address.attributes.except('created_at','updated_at','id'))
          raise SyException, address.errors.full_messages.first unless address.save

          # Clone payment gateways associations
          @re.event_payment_gateway_associations.each do |_association|
            association = @event.event_payment_gateway_associations.build(_association.attributes.except('created_at','updated_at','id'))
            raise SyException, association.errors.full_messages.first unless association.save
          end
        end

        result = @event.reload

      rescue SyException => e
        is_error = true
        result = e.message
        Rails.logger.info("Manual exception: #{e.message}")
      rescue Exception => e
        is_error = true
        result = e.message
        Rails.logger.info("Runtime Exception: #{e.message}")
        Rails.logger.info(e.backtrace)
      end
      unless is_error
        render json: result
      else
        render json: {key: [result]}, status: :unprocessable_entity
      end
    end


    def own_event
      registered_events = current_user.valid_registered_center_event_ids
      @events = Event.where("id IN (?) OR creator_user_id = ?", registered_events, current_user.id)
      if @events.count > 0
        render json: @events
      else
        render json:   []
      end
    end

    def own_event_paginated
      registered_events = current_user.valid_registered_center_event_ids
      @events = Event.where('id IN (?) OR creator_user_id = ?', registered_events, current_user.id).page(params[:page]).per(params[:per_page])
      if @events.count > 0
        render json: @events, serializer: PaginationSerializer
      else
        render json:   []
      end
    end

    # GET /events/events_excel
    def events_excel
      begin
        params[:criterion] ||= 'event_start_date'
        params[:from] ||= (Date.today - 10.years).to_s
        params[:to] ||= (Date.today + 10.years).to_s

        raise SyException, 'Please select a valid from date.' unless params[:from].try(:to_date).present?
        raise SyException, 'Please select a valid to date.' unless params[:to].try(:to_date).present?
        raise SyException, 'Please select a valid criterion.' unless %w(event_start_date event_end_date).include?(params[:criterion])

        event = Event.last

        # Is user authorized to perform oprtation
        raise SyException, 'You are not authorized to perform this action.' unless EventPolicy.new(current_user, event).events_excel?

        recipients = params[:email].try(:split, ',').try(:extract_valid_emails).try(:uniq)

        if recipients.present?
          event.delay.process_report_generate(params.slice(:from, :to, :criterion).merge({recipients: recipients, user_id: current_user.id}))
        else
          blob = event.process_report_generate(params.slice(:from, :to, :criterion).merge({user_id: current_user.id}))
        end

      rescue SyException => e
        is_error = true
        result = e.message
        Rails.logger.info("Manual exception: #{e.message}")
      rescue Exception => e
        is_error = true
        result = e.message
        Rails.logger.info("Runtime Exception: #{e.message}")
        Rails.logger.info(e.backtrace)
      end
      # Decision based on is error
      if is_error
        render file: 'customs/422.html.erb', :locals => {title: 'Events Report Download Error.', message: result }
      else
        if recipients.present?
          render file: 'customs/success.html.erb', :locals => {title: '', message: "Soon you will get an email on #{recipients.to_sentence}." }
        else
          send_data blob, :filename => "events_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"
        end
      end
    end

    def i_card
      begin
        if params.has_key?('event_id') and params[:event_id].present?
          @event = Event.find(params[:event_id])
          raise SyException, 'Please input valid event id.' unless @event.present?

          # Is user authorized to perform oprtation
          raise SyException, 'You are not authorized to perform this action.' unless EventPolicy.new(current_user, @event).i_card?

          begin
            event_registrations_count = Timeout.timeout(5) do
              EventRegistration.where(event_id: params[:event_id], status: EventRegistration.valid_registration_statuses).count
            end
          rescue Timeout::Error
            raise SyException, 'We cannot process your request for such large data. Please use email option.'
          end

        elsif params.has_key?('reg_ref_number') and params[:reg_ref_number].present?

          @event_order = EventOrder.find_by(reg_ref_number: params[:reg_ref_number])

          raise SyException, 'Please input valid registration refernce number.' unless @event_order.present?

          @event = @event_order.event

          begin
            event_registrations_count = Timeout.timeout(5) do
              EventRegistration.where(event_order_id: @event_order.id, status: EventRegistration.valid_registration_statuses).count
            end
          rescue Timeout::Error
            raise SyException, 'We cannot process your request for such large data. Please use email option.'
          end
        else
          raise SyException, 'Please input either reg_ref_number or event id to generate id cards.'
        end

        recipients = (params[:email].try(:split, ',').try(:extract_valid_emails).try(:uniq) || [])

        sync = (not recipients.present?)

        opts = params.slice(:event_id).merge({event_order_id: @event_order.try(:id)})

        raise SyException, "Total i-Cards are #{event_registrations_count}. We cannot process more than 252 cards at a time. Please use email option to generate i-cards." if sync and event_registrations_count > 252

        t_config = {file_name: 'i_cards_generation_result', prefix: "#{ENV['ENVIRONMENT']}/event_i_cards", template: 'search_sadhak_result', sync: sync}

        task = Task.new(taskable_id: current_user.try(:id), taskable_type: 'User', email: recipients.join(','), opts: opts, t_config: t_config)

        raise SyException, task.errors.full_messages.first unless task.save

        task.add_start_block do |parent_task, params = {}|

          raise ArgumentError.new('Parent task cannot be blank.') unless parent_task.present?

          if params[:event_id].present?
            event_registrations = EventRegistration.where(event_id: params[:event_id], status: EventRegistration.valid_registration_statuses).order(:serial_number)
          elsif params[:event_order_id].present?
            event_registrations = EventRegistration.where(event_order_id: params[:event_order_id], status: EventRegistration.valid_registration_statuses).order(:serial_number)
          else
            raise SyException, 'Please input either event order id or event id to generate id cards.'
          end

          parent_task.result = event_registrations.pluck(:id)
        end

        task.add_final_block do |sub_task, ids, opts = {}|

          raise ArgumentError.new('Sub task cannot be blank.') unless sub_task.present?

          includable_data = [:event_seating_category_association, :seating_category, {event: [{ address: [:db_country] }, :event_type, :event_seating_category_associations, :seating_categories]}, :event_order_line_item, :sadhak_profile]

          event_registrations = EventRegistration.where(id: ids).includes(includable_data)

          file = generate_pdf((opts[:sync] ? :pdf : :file), event_registrations, 'invoices/registration_i_card.html.erb')

          sub_task.result = {file: file, from: (event_registrations.first.serial_number.to_i + 100), to: (event_registrations.last.serial_number.to_i + 100), format: 'pdf'}
        end

        if sync
          blob = task.create_subtasks(batch_size: 252)
        else
          task.delay.create_subtasks(batch_size: 252)
        end

      rescue SyException => e
        is_error = true
        result = e.message
      rescue Exception => e
        is_error = true
        result = e.message
      end
      # Decision based on is error
      if is_error
        render file: 'customs/422.html.erb', :locals => {title: 'Registration I-Cards Download Error.', message: result }
      else
        if recipients.present?
          render file: 'customs/success.html.erb', :locals => {title: '', message: "I-Cards generation request accepted. Soon you will get an email on #{recipients.to_sentence}." }
        else
          send_data blob, :filename => "i_cards_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.pdf"
        end
      end
    end

    def replicate

      authorize @event

      begin

        params[:replicas] = params[:replicas].to_i

        params[:replicas] = 1 if params[:replicas] <= 0

        raise 'cannot create more than 50 replicas at once.' if params[:replicas] > 50

        recipient = current_user.sadhak_profile.try(:email) || current_user.email

        raise 'No valid sadhak email found. Please update in profile section.' unless recipient.to_s.is_valid_email?

        @event.delay.replicate(params.slice(:replicas).merge({user_id: current_user.id, recipient: recipient}))

      rescue Exception => e
        message = e.message
      end

      if message.present?
        render json: {errors: [message]}, status: :unprocessable_entity
      else
        render json: {success: ["Request submitted successfully. Soon you will get an email on #{recipient}"]}
      end

    end

    def by_gender

      authorize @event

      data = []

      begin

        genders = %w(male female)

        data = @event.registered_sadhak_profiles.group(:gender).count

        data = genders.collect{ |gender| {name: gender, count: data[gender].to_i} }

      rescue Exception => e
      end

      render json: data

    end

    def by_category

      authorize @event

      data = []

      begin

        data = @event.event_seating_category_associations.collect do |event_seating_category_association|

          {
            name: event_seating_category_association.category_name,
            count: event_seating_category_association.valid_event_registrations.count
          }

        end

      rescue Exception => e

      end

      render json: data

    end

    def by_mode_of_payment

      authorize @event

      data = []

      begin

        @event.event_orders.joins(:event_registrations).where(event_registrations: {status: EventRegistration.valid_registration_statuses}).group(:payment_method).count.each do |k, v|

          gateway = TransferredEventOrder.gateways.find{|g| g[:payment_method] == k}

          k = 'Others' unless gateway.present?

          found = data.find{|o| o[:name] == k }

          if found.present?

            found[:count] = found[:count].to_i + v.to_i

          else

            data << {name: k, count: v}

          end

        end

      rescue Exception => e

      end

      render json: data

    end

    def by_profession

      authorize @event

      data = []

      begin

        data = @event.registered_sadhak_profiles.joins(:profession).group('professions.name').count

        data = Profession.all.collect{|profession| {name: profession.name, count: data[profession.name].to_i}  }

      rescue Exception => e
      end

      render json: data

    end

    def by_category_and_mode_of_payment

      authorize @event

      data = []

      begin

        @event.event_seating_category_associations.each do |event_seating_category_association|

          payment_info = event_seating_category_association.valid_event_registrations.joins(:event_order).group('event_orders.payment_method').count

          categorized_payments = {}

          TransferredEventOrder.gateways.each do |g|

            if g[:gateway_type] == 'online'

              categorized_payments["Online Payment"] = categorized_payments["Online Payment"].to_i + payment_info[g[:payment_method]].to_i

            else

              categorized_payments[g[:payment_method].titleize] = categorized_payments[g[:payment_method].titleize].to_i + payment_info[g[:payment_method]].to_i

            end

          end

          data << categorized_payments.merge({total: categorized_payments.values.map(&:to_i).sum, name: event_seating_category_association.category_name})

        end

      rescue Exception => e

      end

      render json: data

    end

    def payment_info

      authorize @event

      data = []

      begin

        txn_hash = @event.transactions_report(@event.event_order_ids)

        data = %w(online cash dd blessed).collect do |mode|

          {
            name: "#{mode} Payment".titleize,
            pending: txn_hash["#{mode}_pending"].to_f,
            approved: txn_hash["#{mode}_approved"].to_f
          }

        end

      rescue Exception => e

      end

      render json: data

    end

    def payment_info_by_rc

      authorize @event

      data = []

      begin

        @event.registration_centers.each do |rc|

          event_order_ids = @event.event_orders.joins(:registration_center).where(registration_centers: {id: rc.id}).pluck("event_orders.id")

          txn_hash = @event.transactions_report(event_order_ids)

          mode_wise_data = %w(online cash dd blessed).collect do |mode|

            {
              name: "#{mode} Payment".titleize,
              pending: txn_hash["#{mode}_pending"].to_f,
              approved: txn_hash["#{mode}_approved"].to_f
            }

          end

          data << { name: rc.name, approved: mode_wise_data.collect{|o| o[:approved].to_i }.sum.to_f, pending: mode_wise_data.collect{|o| o[:pending].to_i}.sum.to_f }

        end

      rescue Exception => e
      end

      render json: data

    end

    def by_age_group

      authorize @event

      data = []

      begin

        max_age = 100

        start_age = 0

        age_diff = 20

        loop do

          range_year = Date.today.year - start_age - age_diff

          count = @event.registered_sadhak_profiles.where('extract(year from date_of_birth) < ? AND  extract(year from date_of_birth) >= ?', Date.today.year - start_age, range_year).count

          data << { min: start_age + 1, max: start_age + age_diff, age_group: "#{start_age + 1}-#{start_age + age_diff} yrs", count: count }

          start_age += age_diff

          break if start_age >= max_age

        end

      rescue Exception => e
      end

      render json: data

    end

    def by_previous_events_registered

      authorize @event

      data = []

      begin

        data = SadhakProfile.where(id: @event.registered_sadhak_profiles.pluck(:id)).joins(event_registrations: [:event]).where("event_registrations.status IN (?) AND event_registrations.event_id != ?", EventRegistration.valid_registration_statuses, @event.id).group('sadhak_profiles.id').count(:event_id).group_by{|k, v| v }.collect{|k, v| {name: "#{k} events", count: v.size} }

      rescue Exception => e
      end

      render json: data

    end

    def update_ashram_residential_shivirs_dates

      begin

        raise 'You are not authorize to perform this action' unless EventPolicy.new(current_user, nil).update_ashram_residential_shivirs_dates?

        header = %w(EVENT_ID OLD_EVENT_NAME OLD_EVENT_START_DATE OLD_EVENT_END_DATE NEW_EVENT_NAME NEW_EVENT_START_DATE NEW_EVENT_END_DATE)

        # City Name, Existing Batch Start Date, Event Name (Without Dates), New Batch Start Date and Duration (in days)

        city = DbCity.find_by_name(update_ashram_residential_shivirs_dates_params[:city_name])

        raise "Could not find city with name: #{update_ashram_residential_shivirs_dates_params[:city_name]}" unless city.present?

        (Date.strptime(update_ashram_residential_shivirs_dates_params[:existing_batch_stdt], '%Y-%m-%d').present? rescue false) or raise 'Please provide a valid existing batch event start date.'

        (Date.strptime(update_ashram_residential_shivirs_dates_params[:existing_batch_last_eddt], '%Y-%m-%d').present? rescue false) or raise 'Please provide a valid existing batch event last date.'

        (Date.strptime(update_ashram_residential_shivirs_dates_params[:new_batch_stdt], '%Y-%m-%d').present? rescue false) or raise 'Please provide a valid new batch start date.'

        raise "Please provide event name without dates." unless update_ashram_residential_shivirs_dates_params[:event_name].present?

        raise "Please provide duration of event (in days numeric)." unless update_ashram_residential_shivirs_dates_params[:duration_in_days].to_i > 0

        raise "Please provide gap between two successive events (in days numeric)." unless update_ashram_residential_shivirs_dates_params[:days_gap_btw_2_successive_events].to_i > 0

        events = Event.joins(:event_type, :address).where(addresses: {city_id: city.id}, event_types: {name: 'Ashram Residential Shivirs'}).where('events.event_start_date >= ? AND events.event_end_date < ?', Date.strptime(update_ashram_residential_shivirs_dates_params[:existing_batch_stdt], '%Y-%m-%d'), Date.strptime(update_ashram_residential_shivirs_dates_params[:existing_batch_last_eddt], '%Y-%m-%d')).order(:id)

        raise 'Please select a valid criterion. No events found to modify.' if events.count.zero?

        rows = []

        row = []

        ActiveRecord::Base.transaction do

          events.each_with_index do |event, i|

            row = [event.id, event.event_name, event.event_start_date.to_s, event.event_end_date.to_s]

            raise "Event: #{event.event_name} has #{event.event_registrations.count} registrations. cannot update event date." if event.event_registrations.count > 0

            stdt = Date.strptime(update_ashram_residential_shivirs_dates_params[:new_batch_stdt], '%Y-%m-%d').to_date + update_ashram_residential_shivirs_dates_params[:days_gap_btw_2_successive_events].to_i * i
            eddt = stdt + update_ashram_residential_shivirs_dates_params[:duration_in_days].to_i

            event_dates = if (eddt.present? and stdt.present?) then
              if (stdt.year == eddt.year and stdt.month == eddt.month and stdt.day == eddt.day) then
                "#{stdt.day}#{ActiveSupport::Inflector.ordinal(stdt.day)} #{stdt.strftime('%B')} #{stdt.strftime('%Y')}"
              else
                if (stdt.year == eddt.year and stdt.month == eddt.month) then
                  "#{stdt.day}#{ActiveSupport::Inflector.ordinal(stdt.day)} to #{eddt.day}#{ActiveSupport::Inflector.ordinal(eddt.day)} #{stdt.strftime('%B')} #{stdt.strftime('%Y')}"
                else
                  (stdt.year == eddt.year) ? "#{stdt.day}#{ActiveSupport::Inflector.ordinal(stdt.day)} #{stdt.strftime('%B')} to #{eddt.day}#{ActiveSupport::Inflector.ordinal(eddt.day)} #{eddt.strftime('%B')} #{stdt.strftime('%Y')}" : "#{stdt.day}#{ActiveSupport::Inflector.ordinal(stdt.day)} #{stdt.strftime('%B')} #{stdt.strftime('%Y')} to #{eddt.day}#{ActiveSupport::Inflector.ordinal(eddt.day)} #{eddt.strftime('%B')} #{eddt.strftime('%Y')}"
                end
              end
            else
              'NA'
            end

            raise event.errors.full_messages.first unless event.update_columns(event_start_date: stdt.to_s, event_end_date: eddt.to_s, event_name: "#{update_ashram_residential_shivirs_dates_params[:event_name]} (#{event_dates})")

            row << event.event_name

            row << event.event_start_date.to_s

            row << event.event_end_date.to_s

            rows << row

          end

        end

        recipients = []
        recipients << current_user.email
        recipients << current_user.sadhak_profile.try(:email)
        recipients = recipients.extract_valid_emails.uniq

        ApplicationMailer.send_email(
          recipients: recipients,
          subject: "Ashram Residential Shivirs Details Changes Report",
          attachments: Hash["ashram_residential_shivirs_event_update_report_#{DateTime.now.strftime('%F %T')}.xls", GenerateExcel.generate(header: header, rows: rows)]
        ).deliver if rows.size > 0

      rescue Exception => e
        message = e.message
      end

      if message.present?
        render file: 'customs/422.html.erb', :locals => { title: 'Ashram Residential Shivirs Details Changes Error.', message: message }
      else
        render file: 'customs/success.html.erb', :locals => { title: '', message: "Soon you will get an email on #{recipients.to_sentence}." }
      end

    end

    def locate_collection
      @events = EventPolicy::Scope.new(current_user, Event).resolve(filtering_params).includes(:event_type)
    end

    def locate_paginated_collection
      @events = EventPolicy::Scope.new(current_user, Event).resolve(filtering_params).page(params[:page]).per(params[:per_page]).includes(:event_type)
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      # params[:event][:payment_gateway_ids] ||= []
      params.require(:event).permit(:event_name, :event_start_date, :event_end_date, :creator_user_id, :cannonical_event_id, :event_proposal_id, :daily_start_time, :daily_end_time, :description, :graced_by, :contact_details, :video_url, :demand_draft_instructions, :status, :event_type_id, :payment_category, :total_capacity, :contact_email, :website, :event_start_time, :event_end_time, :additional_details, :venue_type_id, :is_photo_proof_required, :show_seats_availability, :event_location, :status_changes_notes, :is_club_event, :show_shivir_price, :pre_approval_required, :full_profile_needed, :pay_in_usd, :entity_type, :entity_key, :registrations_recipients, :reference_event_id, :sy_event_company_id, :payment_gateway_ids, :event_cancellation_plan_id, :automatic_refund,  :discount_plan_id, :has_seva_preference, :approver_email, :logistic_email, :end_date_ignored, :prerequisite_message, :notification_service, :shivir_card_enabled, :discount_text, :prerequisite_event_ids, :event_type_ids, :payment_gateway_ids => [], :prerequisite_event_ids => [], :event_type_ids => [])
    end

    def filtering_params
      params.slice(:event_type_id, :country_id, :sy_club_id, :entity_type, :status, :event_end_date, :graced_by, :state_id, :city_id, :ordered, :event_start_date)
    end

    def list_params
      params.slice(:event_type_id, :country_id, :sy_club_id, :entity_type, :from_date, :to_date, :status, :graced_by, :limit)
    end

    def update_ashram_residential_shivirs_dates_params
      params.require(:event).permit(:city_name, :existing_batch_stdt, :new_batch_stdt, :event_name, :duration_in_days, :days_gap_btw_2_successive_events)
    end
  end
end
