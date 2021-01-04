module Api::V1
  class EventOrdersController < BaseController
    include ActionView::Helpers::NumberHelper

    before_action :authenticate_user!, :except => [:create, :show, :sbm_response, :pay, :demand_draft_payment, :ccavenue_payment_information, :payment_refunds, :send_refund_email, :index, :change_line_item_status, :registration_upgrades, :resend_transaction_receipt_email, :check_order, :get_tax_details, :blessed_payment, :edit_before_pay, :pre_approval_event_application]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:create, :show, :sbm_response, :pay, :demand_draft_payment, :ccavenue_payment_information, :payment_refunds, :send_refund_email, :index, :change_line_item_status, :registration_upgrades, :resend_transaction_receipt_email, :check_order, :get_tax_details, :blessed_payment, :edit_before_pay, :pre_approval_event_application]

    before_action :set_event_order, only: [:show, :edit, :update, :destroy, :sbm_response]
    respond_to :json
    # require 'resolv-replace'
    # require 'net/http'
    # require "uri"
    # GET /event_orders
    def index
         render :json => @event_orders, serializer: PaginationSerializer
      # end
      # render json: sadhak
      # syid =  @event_orders.last.event_order_line_items.all.map{|e|[e.sadhak_profile.syid] }
      # render json: @event_orders
      # render json: @sadhak_profiles, each_serializer: UnapprovedSadhakProfileSerializer
      # , event_order_line_items: @event_orders.last.event_order_line_items}
    end

    # GET /event_orders/1
    def show
      #authorize @event_order
      render json: @event_order
    end

    # GET /event_orders/new
    def new
      @event_order = EventOrder.new
    end

    # GET /event_orders/1/edit
    def edit
    end

    def create
      if params.has_key?('method') and !params[:method].nil? and event_order_params.has_key?('event_id') and !event_order_params[:event_id].nil?
        if params[:method] == 'transfer'
          if params.has_key?('parent_event_order_id') and !params[:parent_event_order_id].nil?
            create_new_transferred_event_order
          else
            error(['Parent event order id is missing'])
          end
        elsif params[:method] == 'club_order' and params.has_key?('sy_club_id') and params[:sy_club_id].present?

          @event_order = create_new_forum_event_order(event_order_params, params[:sy_club_id])
            if @event_order
              render json: {orderId: @event_order.id, reg_ref_number: @event_order.reg_ref_number}
            # else
            #   error(['Event Order Missing'])
            end
        else
          @event_order = create_new_event_order
          if @event_order
            render json: {orderId: @event_order.id, reg_ref_number: @event_order.reg_ref_number}
          end
        end
      else
        error(['Parameters missing'])
      end
    end

    def pre_approval_event_application
      begin
        message = nil
        crypto = Crypto.new
        begin
          decrypted_data = crypto.decrypt(params[:token], Rails.application.secrets.secret_key_base)
        rescue Exception => e
          message = 'Invalid token.'
        end
        raise message if message.present?
        reg_ref_number, timestamp, action = decrypted_data.split(',')
        event_order = EventOrder.find_by(reg_ref_number: reg_ref_number)
        raise 'Event application is not found. Please contact Ashram.' unless event_order.present?
        raise 'Event end date cannot blank. Please contact Ashram' unless event_order.event.event_end_date.present?
        raise 'Event is closed. Please contact Ashram.' if event_order.event.event_end_date < Time.zone.now.to_date
        raise 'Action has been already taken for this application.' if EventOrder.statuses.pending != EventOrder.statuses[event_order.status]
        if EventOrder.statuses['approve'] == EventOrder.statuses[action]
          event_order.update(status: EventOrder.statuses[action])
          message = "Application with reference number #{event_order.reg_ref_number} has been approved successfully."
        elsif EventOrder.statuses['rejected'] == EventOrder.statuses[action]
          event_order.update(status: EventOrder.statuses[action])
          message = "Application with reference number #{event_order.reg_ref_number} has been disapproved successfully."
        else
          message = 'Please select a valid action (approve/reject).'
        end
        from = GetSenderEmail.call(event_order.event)
      rescue Exception => e
        message = e.message
      end
      render file: 'event_orders/pre_approval_event_application', :locals => {data: event_order, message: message, from: from}
    end

    def create_new_transferred_event_order
      begin
        # To verify that parent event order is having status as success or dd_received_by_ashram
        parent_eo = EventOrder.find_by_id(params[:parent_event_order_id])
        raise SyException, "Parent event order not found." unless parent_eo.present?
        raise SyException, "We are unable to process your request as payment status is pending or demand draft is not reached to Ashram." unless ["success", "dd_received_by_ashram"].include?(parent_eo.status)

        clp_event_ids = (GlobalPreference.get_value_of('india_clp_events').to_s.split(',') + GlobalPreference.get_value_of('global_clp_events').to_s.split(',')).map { |id| id.to_i }

        raise SyException, 'Shivir Change is not allowed on CLP.' if clp_event_ids.include?(parent_eo.event_id)

        # Block shivir transfer for event type 1k shivir(s)
        raise 'Transfer is not allowed on 1k shivir(s).' unless EventOrderPolicy.new(current_user, parent_eo).can_transfer_1k_shivir_to_any_shivir_or_vice_versa? && EventOrderPolicy.new(current_user, Event.find_by_id(event_order_params[:event_id]).try(:event_orders).try(:build)).can_transfer_1k_shivir_to_any_shivir_or_vice_versa?

        # Create a fresh event order
        transferred_event_order = create_new_event_order
        if transferred_event_order
          # Create a trnaferred event order entry
          teo = TransferredEventOrder.new(child_event_order_id: transferred_event_order.id, parent_event_order_id: params[:parent_event_order_id])
          raise SyException, teo.errors.full_messages.first unless teo.save

          # Update if amount is refundable amount or no amount paid
          EventOrder.update_transferred_order(transferred_event_order, event_order_params)

          render json: {orderId: transferred_event_order.id, reg_ref_number: transferred_event_order.reg_ref_number}
        end
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        message = e.message
      end
      # Send error to UI
      if message.present?
        error([message])
      end
    end

    def create_new_event_order
      # check if event_id and sadhak_profiles information is passed
      if event_order_params.has_key?('event_id') and event_order_params.has_key?('sadhak_profiles')
        @event = Event.where(id: event_order_params[:event_id]).includes(:prerequisite_events, :event_prerequisites_event_types).last

        # Method call to validate forum details and profile details if sy club id present
        err_message = event_order_params[:sy_club_id].present? ? EventOrder.validate_forum_details(event_order_params) : ''
        if err_message.present?
          error([err_message], 'Forum:')
          return false
        else
          # check if event found and status of event allows registrations
          if @event.present?
            is_event_running = (@event.end_date_ignored? || (@event.event_end_date.present? && Date.today <= @event.event_end_date))
            is_admin = EventOrderPolicy.new(current_user, @event.event_orders.build).create?
            is_rc = SadhakProfile.last.verify_by_rc(current_user, @event.id)
            if is_event_running || is_admin || is_rc
              if @event.status == 'test_registration' || @event.status == 'ready' || is_admin || is_rc

                Rails.logger.info("Guest Email Before: #{event_order_params[:guest_email]}")

                # Assign dummy email if not a valid guest email found
                guest_email = if event_order_params[:guest_email].present? then
                                event_order_params[:guest_email]
                              else
                                current_user.try(:sadhak_profile).try(:email).present? ? current_user.sadhak_profile.email : 'syitemails@gmail.com'
                              end

                if guest_email.present?
                  errors = []
                  valid_profiles_to_register = []
                  seating_categories_requested = []
                  event_order_params['sadhak_profiles'].each_with_index do |sp, i|
                    # check if syid was passed with the sadhak details
                    if sp.has_key?('syid')
                      sadhak_profile = SadhakProfile.find_by(:syid => sp['syid'])
                      # check if sadhak_profile is found by syid
                      if !sadhak_profile.nil?
                        #check if first name matches with the syid
                        if sp.has_key?('first_name') and sp['first_name'] == sadhak_profile.first_name
                          # Check that sadhak profile is banned or not
                          if not sadhak_profile.banned?
                            #check if sadhak already registered for the event
                            if !sadhak_profile.events.include?(@event) or (event_order_params[:sy_club_id].present? and (sadhak_profile.renewal_events || []).include?(@event))
                              if sadhak_profile.check_prerequisite_criterion?(@event)
                                if @event.pre_approval_required?
                                  existing_application = @event.event_order_line_items.where(sadhak_profile: sadhak_profile, status: EventOrderLineItem.valid_line_item_statuses).last
                                  if existing_application.present?
                                    sp[:message] = "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid} is already applied for this event with reg ref number: #{existing_application.reg_ref_number}."
                                    sp['error'] = sp[:message]
                                    errors.push(sp)
                                  end
                                end
                                if @event.is_ashram_residential_shivir? && EventOrderLineItem.joins(event: [:event_type]).where('event_order_line_items.sadhak_profile_id = ? AND event_order_line_items.created_at > ? AND event_order_line_items.created_at <= ? AND event_types.name = ?', sadhak_profile.id, (Time.zone.now - 6.months).beginning_of_day, Time.zone.now, ASHRAM_RESIDENTIAL_SHIVIR).exists?
                                  sp[:message] = "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid} is only allowed to apply for residential shivirs once every 6 months."
                                  sp['error'] = sp[:message]
                                  sp[:is_ashram_residential_shivir] = true
                                  errors.push(sp)
                                end
                                sp[:id] = sadhak_profile.id
                                sp[:first_name] = sadhak_profile.first_name
                                sp[:is_extra_seat] = sp[:is_extra_seat] ? sp[:is_extra_seat] : false
                                sp[:available_for_seva] = sp[:available_for_seva] if sp[:available_for_seva].present? and sp[:available_for_seva] == 'true' and @event.has_seva_preference?
                                scr = seating_categories_requested.find {|sc| sc[:id] == sp['event_seating_category_association_id'] }
                                if scr.nil?
                                  seating_categories_requested.push({:id => sp['event_seating_category_association_id'], :seats_requested => 1, :sadhaks => [sadhak_profile.id]})
                                else
                                  scr[:seats_requested] += 1
                                  scr[:sadhaks].push(sadhak_profile.id)
                                end
                                valid_profiles_to_register.push(sp)
                              else
                                sp[:message] = "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid} does not meet prerequisite criterion"
                                prerequisite_events_string = (@event.prerequisite_events + Event.where(event_type_id: @event.event_prerequisites_event_types.pluck(:event_type_id))).collect{|e| e.event_name_with_location}.join(' | ')
                                sp['error'] = @event.prerequisite_message.present? ? @event.prerequisite_message : "In order to register for #{@event.event_name}, it is mandatory that you have attended #{prerequisite_events_string}."
                                errors.push(sp)
                              end
                            else
                              sp[:message] = "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid}"
                              sp['error'] = 'Sadhak Profile already registered for this event.'
                              errors.push(sp)
                            end
                          else
                            sp[:message] = "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid} is not allowed to register. Please contact Ashram."
                            errors.push(sp)
                          end
                        else
                          sp['error'] = 'syid does not match with the first name.'
                          errors.push(sp)
                        end
                      else
                        sp['error'] = 'Sadhak Profile not found.'
                        errors.push(sp)
                      end
                    else
                      sp['error'] = 'SYID not specified'
                      errors.push(sp)
                    end
                  end

                  #all sadhak profiles are valid to be added to event order line items
                  if errors.count == 0
                    seating_capacity_errors = []
                    seating_categories_requested.each do |scr|
                      event_seating_category_association_model = EventSeatingCategoryAssociation.find(scr[:id])
                      #check if EventSeatingCategoryAssociation found`
                      if !event_seating_category_association_model.nil?
                        #check if EventSeatingCategoryAssociation belongs to the requested event
                        if event_seating_category_association_model.event == @event
                          #check if number of seats requested are available in this category
                          seats_occupied = @event.event_registrations.where(:event_seating_category_association_id  => scr[:id], :status => EventOrderLineItem.valid_line_item_statuses).count
                          total_seats = event_seating_category_association_model.seating_capacity
                          seats_available = total_seats - seats_occupied
                          if current_user.present? and (current_user.super_admin? or current_user.event_admin?)
                            seats_available < scr[:seats_requested] and scr[:sadhaks].each do |sadhak_id|
                              sp = valid_profiles_to_register.find {|s| s[:id] == sadhak_id }
                              sp[:is_extra_seat] = seats_available < 1
                              seats_available -= 1
                            end
                          else
                            #check if requested number of seats are available
                            if seats_available < scr[:seats_requested]
                              if seats_available <= 0
                                errorText = "No seats available in #{event_seating_category_association_model.seating_category.category_name} category"
                                errorObj= {
                                  errors:{
                                    seating_capacity: [errorText]
                                    }
                                  }
                                render json:  errorObj, status: :unprocessable_entity
                                return false
                              elsif seats_available == 1
                                errorText = "Only 1 seat is available in  #{event_seating_category_association_model.seating_category.category_name} category"
                                 errorObj= {
                                   errors:{
                                     seating_capacity: [errorText]
                                     }
                                   }
                                render json:  errorObj, status: :unprocessable_entity
                                return false
                              else
                                errorText = "Only #{seats_available} seats are available in  #{event_seating_category_association_model.seating_category.category_name} category"
                                errorObj= {
                                  errors:{
                                    seating_category: [errorText]
                                    }
                                  }
                                render json:  errorObj, status: :unprocessable_entity
                                return false
                              end
                              seating_capacity_errors.push({:event_seating_category_association_id => scr[:id], :error => errorText})
                            end
                          end
                        else
                          seating_capacity_errors.push({:event_seating_category_association_id => scr[:id], :error => 'Seating category does not belong to requested event'})
                        end
                      else
                        seating_capacity_errors.push({:event_seating_category_association_id => scr[:id], :error => 'Seating category not found'})
                      end
                    end
                    if seating_capacity_errors.count == 0
                      #all good, we can continue with the order create
                      #valid_profiles_to_register
                      event_order_hash = {event_id: @event.id, user_id: current_user.try(:id), guest_email: guest_email, sy_club_id: event_order_params[:sy_club_id]}
                      @event_order = EventOrder.new(event_order_hash)
                      if params.has_key?(:rc_user) and params[:rc_user] == 1
                        @event_order.registration_center_user_id = @event.get_registration_center_user_id(current_user.id)
                      end

                      if @event_order.save
                        # registration_number = @event_order.id.to_f
                        #   render json: registration_number
                        # return false
                        valid_profiles_to_register.each do |vp|
                          event_seating_category_association_model = EventSeatingCategoryAssociation.find(vp[:event_seating_category_association_id ])
                          event_order_line_item_hash = {sadhak_profile_id: vp[:id], event_seating_category_association_id: event_seating_category_association_model.id, price: event_seating_category_association_model.price, seating_category_id: event_seating_category_association_model.seating_category.id, is_extra_seat: vp[:is_extra_seat], available_for_seva: vp[:available_for_seva]}
                          @event_order.event_order_line_items.create(event_order_line_item_hash)
                        end
                        @event_order.delay.pre_approval_application_details if @event.pre_approval_required?
                        return @event_order
                      else
                        render json: {error: 1, message: @event_order.errors }, status: :unprocessable_entity
                        return false
                      end
                    else
                      # render json: {error: 1, event_seating_category_associations: seating_capacity_errors}, status: :unprocessable_entity
                      errorObj= {
                        errors:{
                          seating_category: seating_capacity_errors
                          }
                        }
                      render json:  errorObj, status: :unprocessable_entity
                      return false
                    end
                  else
                    # render json: {error: 1, sadhak_profiles: errors}, status: :unprocessable_entity
                          errorObj= {
                              errors:{
                                profile: errors
                                # sadhak_profile: errors
                                }
                              }
                            render json:  errorObj, status: :unprocessable_entity
                            return false
                  end
                else
                  render json: {error: 1, message: 'Guest email cannot be empty for non logged in users'}, status: :unprocessable_entity
                  return false
                end
              else
                error(['Event is not ready for Registrations. Please contact Ashram.'])
              end
            else
              error(['Event is closed. Please contact Ashram.'])
            end
          else
            error(['Event not found.'])
          end
        end
      else
        error(['Parameters missing.'])
      end
    end

    def payment_url
      order_num = @event_order.id.to_s + "_" + Time.now.to_f.to_s + '_' + 'event-order'
      currency = "480"
      redirect_url = Rails.application.config.app_base_url.to_s() + "/event_orders/sbm_response"
      custom_params = {:id => @event_order.id}
      redirect_url = redirect_url + "?" + custom_params.to_query
      amount = @event_order.total_amount

      request_params = Hash.new
      request_params[:userName] = ENV['SBM_USER'].to_s()
      request_params[:password] = ENV['SBM_PASS'].to_s()
      request_params[:orderNumber] = order_num
      request_params[:amount] = amount
      request_params[:currency] = currency
      request_params[:returnUrl] = redirect_url

      uri = URI.parse(ENV['SBM_URL'].to_s() + ENV['SBM_REGISTER_ENDPOINT'].to_s())
      uri.query = URI.encode_www_form(request_params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      logger.info uri.request_uri
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      logger.info response.body
      response_hash = JSON.parse response.body

      if response_hash.has_key?("errorCode") and response_hash["errorCode"] == "1"
        # handle case when order already exists and not paid yet
        # currently handling by passing the current timestamp along with order id
        render json: { status: "Failed", hash: response_hash }
      else
        @event_order.payment_gateway_response = response_hash.to_json
        @event_order.save
        render json: response_hash
      end
    end

    def sbm_response
      if @event_order.status == 'cart'
        order_status_params = Hash.new
        order_status_params[:userName] = ENV['SBM_USER'].to_s()
        order_status_params[:password] = ENV['SBM_PASS'].to_s()
        order_status_params[:orderId] = params[:orderId]
        order_status_params[:language] = "en"

        order_status_uri = URI.parse(ENV['SBM_URL'].to_s() + ENV['SBM_ORDER_STATUS_ENDPOINT'].to_s())
        http = Net::HTTP.new(order_status_uri.host, order_status_uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(order_status_uri.request_uri)
        request.set_form_data(order_status_params)
        response = http.request(request)
        response_hash = JSON.parse response.body
        order_num = response_hash["OrderNumber"]
        order_num = order_num.split(/_/)
        # check if order_id from URL Matches with the order id obtained from payment gateway
        if (order_num.count > 0) and (order_num[0].to_f == @event_order.id)
          if response_hash.has_key?("OrderStatus") and response_hash["OrderStatus"] == 6
            @event_order.payment_gateway_response = params.to_json
            @event_order.successful_payment
            # sending confirmation email
            #UserMailer.event_order_confirmation(current_user, @event_order).deliver
            @event_order.save
            redirect_url = Rails.application.config.app_base_url.to_s() + Rails.application.config.app_url_suffix + "/#/event-order-checkout-success"
            #redirect_to redirect_url
            render plain: redirect_url
            return false
          end
        end
        #order failed
        @event_order.status = :cart
      else
        redirect_url = Rails.application.config.app_base_url.to_s() + Rails.application.config.app_url_suffix + "/#/event-order-checkout"
        #redirect_to redirect_url
        render plain: redirect_url
      end
    end

    def pay
      begin
        @gateway = TransferredEventOrder.gateways.find {|g| g[:symbol] == params[:method] }
        raise SyException, 'Please provide a valid payment method.' unless @gateway.present?

        @event_order = EventOrder.preloaded_data.find_by_id(payment_detail_params[:event_order_id])
        raise SyException, 'Please provide valid event order id.' unless @event_order.present?

        @event = @event_order.event

        is_event_running = (@event.end_date_ignored? || (@event.event_end_date.present? && Date.today <= @event.event_end_date))
        is_admin = EventOrderPolicy.new(current_user, @event_order).pay?
        is_rc = SadhakProfile.last.verify_by_rc(current_user, @event.id)
        raise SyException, 'Event is closed.' unless (is_event_running || is_admin || is_rc)
        raise SyException, 'Event is not ready for registrations.' unless (@event.status == 'test_registration' || @event.status == 'ready' || is_admin || is_rc)

        raise SyException, 'You are not allowed to make Cash Payments.' unless (is_admin || is_rc) if params[:method].in?(['cash'])

        raise SyException, 'You are not allowed to make DD Payments.' unless is_rc if params[:method].in?(['sydd'])

        # Added logic to overcome guest email issue.
        logger.info("EventOrdersController: pay: Guest email for id: #{@event_order.id} is #{@event_order.guest_email}")
        unless @event_order.guest_email.present?
          logger.info("EventOrdersController: pay: Updating guest email for id: #{@event_order.id} to syitemails@gmail.com")
          @event_order.update_column('guest_email', 'syitemails@gmail.com')
        end

        # Assign some values used in gateways
        payment_detail_params[:guest_email] = @event_order.guest_email
        payment_detail_params[:pay_in_usd] = @event_order.event.pay_in_usd

        white_list = %w(razorpay stripe cash sydd ccavenue payfast)

        # Push gateway details to params: payment_detail_params
        payment_detail_params[:gateway] = @gateway

        # Verify UI amount
        raise SyException, 'Invalid payable amount.' if (white_list.include?(@gateway[:symbol]) and !@event_order.is_amount_valid?(payment_detail_params))

        case params[:method]
        when 'sydd'
          demand_draft_payment
        when 'ccavenue'
          ccavenue_payment_information
        when 'cash'
          cash_payment
        when 'stripe'
          stripe_payment
        when 'paypal'
          paypal_payment
        when 'razorpay'
          razorpay_payment
        when 'braintree'
          braintree_payment
        when 'payfast'
          payfast_payment
        else
          message = 'Not a valid payment method.'
        end
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        message = e.message
      end

      # If any error occured
      if message.present?
        error([message])
      end
    end

    def demand_draft_payment
      # Transaction Log
      gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == params[:method]}
      transaction_log = TransactionLog.create(transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params)
      dd, message = PgSyddTransaction.create_payment(payment_detail_params, transaction_log)

      raise SyException, message if message.present?

      begin
        # Update event order line items and event registrations as payment completed.
        dd.event_order.perform_updation(payment_detail_params[:details]) if EventOrder.statuses.slice(:dd_received_by_ashram, :dd_received_by_india_admin, :dd_received_by_rc, :success).values.include?(EventOrder.statuses[dd.event_order.reload.status])
      rescue => e
        Rollbar.error(e)
      end

      render json: dd
    end

    def ccavenue_payment_information
      gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == params[:method]}
      transaction_log = TransactionLog.create(gateway_request_object: payment_detail_params.except(:details), transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params)
      details = OrderPaymentInformation.create_ccavenue_payment(payment_detail_params)
      if details.errors.empty?
        event_order_id =  details.event_order.event_id.to_s + '-' +  details.event_order.reg_ref_number.to_s + '-' + details.id.to_s + '-' + details.created_at.strftime("%m/%d/%Y").to_s.delete('/')
        render json: {event_order_id: event_order_id, transaction_log_id: transaction_log.id}
      else
        raise SyException, "#{details.errors.full_messages.first}"
      end
    end

    def cash_payment
      # Transaction Log
      gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == params[:method]}
      transaction_log = TransactionLog.create(transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params)
      cash_payment, message = PgCashPaymentTransaction.create_payment(payment_detail_params, transaction_log)

      raise SyException, message if message.present?

      begin
        # Update event order line items and event registrations as payment completed.
        cash_payment.event_order.perform_updation(payment_detail_params[:details])
      rescue => e
        Rollbar.error(e)
      end

      # Send joining email
      cash_payment.event_order.reload.notify_joining if cash_payment.try(:event_order).try(:event).try(:notification_service)

      render json: cash_payment
    end

    def stripe_payment
      gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == params[:method]}

      # Transaction Log
      transaction_log = TransactionLog.create(transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params)
      payment, message = StripeSubscription.create_payment(payment_detail_params, transaction_log)

      raise SyException, message if message.present?

      payment.event_order.update_attributes(transaction_id: payment.card, payment_method: 'Stripe Payment', status: payment.status)

      begin
        # Update event order line items and event registrations as payment completed.
        payment.event_order.perform_updation(payment_detail_params[:details])
      rescue => e
        Rollbar.error(e)
      end

      # Send joining email
      payment.event_order.reload.notify_joining if payment.try(:event_order).try(:event).try(:notification_service)

      render json: payment

    end

    def paypal_payment
      if payment_detail_params.has_key?("amount") and payment_detail_params.has_key?("event_order_id") and payment_detail_params.has_key?("acct") and payment_detail_params.has_key?("cvv2") and payment_detail_params.has_key?("last_name") and payment_detail_params.has_key?("street") and payment_detail_params.has_key?("city") and payment_detail_params.has_key?("state") and payment_detail_params.has_key?("zip")and payment_detail_params.has_key?("currency_code") and payment_detail_params.has_key?("exp_date") and payment_detail_params.has_key?("mode") and payment_detail_params.has_key?("config_id") and payment_detail_params.has_key?("first_name") and payment_detail_params[:amount].present? and payment_detail_params[:event_order_id].present? and payment_detail_params[:acct].present? and payment_detail_params[:cvv2].present? and payment_detail_params[:last_name].present? and payment_detail_params[:street].present?  and payment_detail_params[:city].present? and payment_detail_params[:state].present? and payment_detail_params[:zip].present? and payment_detail_params[:currency_code].present? and payment_detail_params[:exp_date].present? and payment_detail_params[:mode].present?  and payment_detail_params[:config_id].present? and payment_detail_params[:first_name].present?
        payment, message = PgSyPaypalPaymentsController.new.paypal_direct_payment(payment_detail_params)
        if !message.present?
          render json: payment
        else
          errorObj= {
            errors:{
              error: [message]
              }
            }
          render json:  errorObj, status: :unprocessable_entity
        end
      else
         errorObj= {
          errors:{
            error: ['Incomplete parameter values']
            }
          }
        render json:  errorObj, status: :unprocessable_entity
      end
    end

    def razorpay_payment
      begin
        # Raise errors if parameters missing
        raise SyException, "Please provide a valid amount." if payment_detail_params[:amount].nil?
        raise SyException, "Please place event order first." if payment_detail_params[:event_order_id].nil?
        raise SyException, "Please provide same transaction log id that been passed during filling card details." if payment_detail_params[:transaction_log_id].nil?

        # Find payment gateway configration
        gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == params[:method]}

        # Controller instance
        controller_instance = gateway.controller.constantize.new

        # Reterive razorpay payment object
        payment_info = controller_instance.send("get_#{gateway[:symbol]}", {config_id: payment_detail_params[:config_id], razorpay_payment_id: payment_detail_params[:razorpay_payment_id]})

        # Verify metadata details.
        raise SyException, "Metadata is altered." if (payment_info.notes.transaction_log_id.to_i != payment_detail_params[:transaction_log_id].to_i or payment_info.notes.event_order_id.to_i != payment_detail_params[:event_order_id].to_i)

        # Find transaction log
        transaction_log = TransactionLog.find_by_id(payment_detail_params[:transaction_log_id])

        # Raise error if no transaction log found
        raise SyException, "Transaction log not found with id: #{payment_detail_params[:transaction_log_id]}" unless transaction_log.present?

        # If found then update and proceed
        raise SyException, "#{transaction_log.errors.as_json(full_messages: true).first}" unless transaction_log.update(transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params)

        # Proceed for payment
        payment, message = controller_instance.create(payment_detail_params, transaction_log)

      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue Exception => e
        message = e.message
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
      end

      # Decision based on message
      unless message.present?
        payment.event_order.update_attributes(transaction_id: payment.razorpay_payment_id, payment_method: 'Razorpay Payment', status: payment.status)

        begin
          # Update event order line items and event registrations as payment completed.
          payment.event_order.perform_updation(payment_detail_params[:details])
        rescue => e
          Rollbar.error(e)
        end

        # Send joining email
        payment.event_order.reload.notify_joining if payment.try(:event_order).try(:event).try(:notification_service)

        render json: payment
      else
        error([message])
      end
    end

    def braintree_payment
      if payment_detail_params.has_key?('event_order_id') and payment_detail_params[:event_order_id].present?
        # Transaction Log
        gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == params[:method]}
        transaction_log = TransactionLog.create(transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params)
        braintree_payment, message = PgSyBraintreePayment.create_braintree_payment(payment_detail_params, transaction_log)
        unless message.present?
          braintree_payment.event_order.update_attributes(transaction_id: braintree_payment.braintree_payment_id, payment_method: 'Braintree Payment', status: braintree_payment.status)

          begin
            # Update event order line items and event registrations as payment completed.
            braintree_payment.event_order.perform_updation(payment_detail_params[:details])
          rescue => e
            Rollbar.error(e)
          end

          # Send joining email
          braintree_payment.event_order.notify_joining if braintree_payment.try(:event_order).try(:event).try(:notification_service)

          render json: braintree_payment
        else
          error([message])
        end
      else
        error(['Event Order id missing.'])
      end
    end

    def payfast_payment
      begin

        raise SyException, "Please input first name." unless payment_detail_params[:name_first].present?
        raise SyException, "Please input last name." unless payment_detail_params[:name_last].present?
        raise SyException, "Please input a valid email address, that will be used to notify payment transaction." unless payment_detail_params[:email_address].to_s.is_valid_email?

        # Find payment gateway configration
        gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == params[:method]}

        transaction_log = TransactionLog.create(transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params)

        url = gateway.model.constantize.create_payfast_payment(payment_detail_params, transaction_log)

      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue Exception => e
        message = e.message
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
      end

      # Decision based on message
      unless message.present?
        logger.info("Redirect url for event_order id: #{@event_order.id} \n #{url}")
        render json: {url: url}
      else
        error([message])
      end
    end

    def payment_refunds
      begin
        result = nil

        # Assign TransferredEventOrder model to variable
        @t = TransferredEventOrder

        @event = Event.includes({event_cancellation_plan: [:event_cancellation_plan_items]}).find_by_id(request_params[:event_id])
        raise SyException, "Event not found." unless @event.present?

        @event_order = EventOrder.includes(:event, :event_order_line_items).find_by_id(request_params[:event_order_id])
        raise SyException, "Event order not found." unless @event_order.present?

        @from_event_order = EventOrder.includes(:event).find_by_reg_ref_number(request_params[:reg_ref_number])
        raise SyException, "Event order is not found with reg_ref_number: #{request_params[:reg_ref_number]}." unless @from_event_order.present?

        @event_order_policy = EventOrderPolicy.new(current_user, @event_order)

        raise SyException, "We are unable to process your request as payment status is pending or demand draft is not reached to Ashram." unless ["success", "dd_received_by_ashram"].include?(@event_order.status)

        sadhak_profiles = request_params[:sadhak_profiles]
        raise SyException, "Please provide sadhak profiles." unless sadhak_profiles.present?

        # Event has been closed. Allowed to super admin and event admin anytime
        raise SyException, "Event registration has been closed. Please contact event organiser for cancellation/downgrade/transfer." unless (@event.event_start_date.present? and DateTime.now <= (@event.event_start_date - 2) || @event_order_policy.payment_refunds?)

        # Block payment refund for particular 1k type shivir(s)
        raise 'Refund is not allowed for 1k type shivir(s).' unless @event_order_policy.can_refund_1k_shivir?

        # Check for ui amount
        ui_amount = request_params[:amount].to_f.round(2)
        raise SyException, "Please input valid amount." if [nil, "", "NULL", "nil"].include?(ui_amount)

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
        db_refundable_amount =  downgraded[:amount]

        # Cancellation charges using cancellation policy
        cancellation_charges_by_policy = @event.cancellation_charges_by_policy(sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]})

        # Authorize request if not an automatic refund
        raise 'You need to sign in or sign up before continuing.' unless current_user.present? unless @event.automatic_refund?

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

        raise SyException, "You can't make refund because available amount #{db_paid_amount} is lesser than requested amount #{ui_amount}, cancellation charges: #{cancellation_charges_by_policy}." if db_paid_amount < (ui_amount + cancellation_charges_by_policy)

        raise SyException, "You can't make refund because requested amount doesn't match." unless db_refundable_amount == ui_amount + cancellation_charges_by_policy

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

        # If automatic refund is true means do instant refund else place request
        if @event.automatic_refund?
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

        data = {refunds: refunds, total_refunded_amount: db_refunded_amount, event_order_id: @event_order.id, event_order_line_item_ids: sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]}, partial_refund: partial_refund}

        result = {success:{Status: [message], data: (ENV["ENVIRONMENT"] == "development" or ENV["ENVIRONMENT"] == "testing") ? data : {}}}
        logger.info(result)

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
      if is_error
        error([result])
      else
        render json: result
      end
    end

    def error(message = 'error', key = 'error')
      errorObj = {errors:{}}
      errorObj[:errors][key.to_s] = message
      render json:  errorObj, status: :unprocessable_entity
      return
    end

    def success(data = {}, message = 'success', key = 'success')
      successObj = {success:{}}
      successObj[:success][key.to_s] = message
      if data.present?
        successObj[:success]['data'] = data
      end
      render json: successObj
      return
    end

    def send_refund_email
      # begin
      #   # Collect line items
      #   line_items = EventOrderLineItem.where(id: refund_email_params[:event_order_line_item_ids])

      #   # Find event order
      #   event_order = EventOrder.find_by_id(refund_email_params[:event_order_id])

      #   # Collect super admin emails
      #   super_admins_email = SadhakProfile.where(user_id: User.where("super_admin = ?", true).pluck(:id)).pluck('DISTINCT email')

      #   # Collect sadhak profile emails
      #   line_items_email = line_items.collect{|item| item.try(:sadhak_profile).try(:email)}

      #   # Commented as email moved inside payment refunds method.
      #   UserMailer.send_email(recipients: event_order.try(:guest_email), cc: line_items_email, bcc: super_admins_email, subject: "Refund Status.", template: 'payment_refund_confirmation', refunds: refund_email_params[:refunds], line_items: line_items, event: event_order.try(:event), total_refunded_amount: refund_email_params[:total_refunded_amount], partial_refund: refund_email_params[:partial_refund]).deliver

      # rescue Exception => e
      #   is_error = true
      #   logger.info("Error occured in sending refund email: #{e.message}")
      #   logger.info(e.backtrace.inspect)
      # end

      # # If any error send error else succes
      # if is_error
      #   error(["Error in sending refund email: #{e.message}"], 'Email Status: ')
      # else
        success({}, ['We have successfully processed your email. Please check your mail box.'], 'Email Status: ')
      # end
    end

    def change_line_item_status
      # sadhak_ids = []
      begin
        raise SyException, "Parameter status is missing." unless change_line_item_status_params[:status].present?
        updated_status = change_line_item_status_params[:status].to_s
        transferred_ref_number = change_line_item_status_params[:transferred_ref_number]

        # raise SyException, "Sadhak profile ids are missing." unless change_line_item_status_params[:sadhak_profile_ids].present?

        # Find event order
        event_order = EventOrder.find_by_id(change_line_item_status_params[:event_order_id])
        raise SyException, "Event order is missing." unless event_order.present?

        # Check for valid status
        raise SyException, "Invalid status for update: #{updated_status}" unless EventRegistration.statuses.keys.include?(updated_status)
        raise SyException, "Invalid status for update: #{updated_status}" unless EventOrderLineItem.statuses.keys.include?(updated_status)

        #changes to read syids as integer
        # (change_line_item_status_params[:sadhak_profile_ids] || []).each do |e|
        #   sadhak_ids.push(e[/-?\d+/].to_i)
        # end

        # Collect all event registrations
        registrations = EventRegistration.includes(:event_order_line_item).where(event_order_line_item_id: change_line_item_status_params[:event_order_line_item_ids])
        raise SyException, "Registrations not found." unless registrations.present?

        # Update event registration and line item status
        registrations.each do |r|
          # Update registration status
          raise SyException, r.errors.full_messages.first unless r.update(status: updated_status)

          # Find line item
          line_item = r.try(:event_order_line_item)
          raise SyException, "Event order line item not found associated with registration id: #{r.try(:id)}" unless line_item.present?

          # Update line item status and trnasferred reference number if present.
          raise SyException, line_item.errors.full_messages.first unless line_item.update(status: updated_status, transferred_ref_number: transferred_ref_number.present? ? transferred_ref_number : line_item.transferred_ref_number)
        end

        # Update event order total amount
        # event_order.update_event_order_total
        # event_order.total_discount = event_order.event_order_line_items.collect{|x| x.discount.to_f}.sum

        # raise SyException, event_order.errors.full_messages.first unless event_order.save

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
      if is_error
        error([result])
      else
        success({}, ["Event registration and line items status updated successfully."])
      end
    end

    def registration_upgrades
      begin
        raise SyException, "Line item ids missing." unless registration_upgrades_params[:event_order_line_item_ids].present?
        raise SyException, "Sadhak profiles are missing." unless registration_upgrades_params[:sadhak_profiles].present?

        # Collect event registrations associated with given line items
        registrations = EventRegistration.includes(:event_order_line_item, :event).where(event_order_line_item_id: registration_upgrades_params[:event_order_line_item_ids])
        raise SyException, "Registrations not found." unless registrations.present?

        # Collect seating category association ids
        seating_associations = EventSeatingCategoryAssociation.where(id: registration_upgrades_params[:sadhak_profiles].collect{|sp| sp[:event_seating_category_association_id]})

        # Perform check that sadhak already joined to this event
        db_sadhaks = SadhakProfile.includes(:events).where(id: registration_upgrades_params[:sadhak_profiles].collect{|sp| sp[:syid]})

        # Update line item and event registration
        registrations.each do |r|
          # Find sadhak profile
          sadhak_profile = registration_upgrades_params[:sadhak_profiles].find{|sp| sp[:event_order_line_item_id].to_i == r.event_order_line_item_id}
          raise SyException, "Sadhak profile updated deatils missing." unless sadhak_profile.present?

          # Find sadhak profile from database
          db_sadhak = db_sadhaks.find{|s| s.id == sadhak_profile[:syid].to_i}

          # Find Line item
          category =  seating_associations.find{|s| s.id == sadhak_profile[:event_seating_category_association_id].to_i}
          # Raise error if no sadhak profile exist in database
          raise SyException, "No seating category found with this id" unless category.present?

          # Raise error if no sadhak profile exist in database
          raise SyException, "No sadhak profile found in database." unless db_sadhak.present?

          # Check wether sadhak is already registered for this event
          raise SyException, "SYID: #{db_sadhak.try(:syid)} Name: #{db_sadhak.try(:full_name)} is already registered to event: #{r.try(:event).try(:event_name)}." if sadhak_profile[:syid].to_i != r.sadhak_profile_id and db_sadhak.event_ids.include?(r.event_id)

          # Find line item
          line_item = r.try(:event_order_line_item)
          raise SyException, "Event order line item not found associated with registration id: #{r.try(:id)}" unless line_item.present?

          # Update registration status
          raise SyException, r.errors.full_messages.first unless r.update(sadhak_profile_id: sadhak_profile[:syid], event_seating_category_association_id: sadhak_profile[:event_seating_category_association_id])

          # Update line item status and trnasferred reference number if present.
          raise SyException, line_item.errors.full_messages.first unless line_item.update(sadhak_profile_id: sadhak_profile[:syid], event_seating_category_association_id: sadhak_profile[:event_seating_category_association_id], price: category.price)
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
      if is_error
        error([result])
      else
        success({}, ["Event registration and line items updated successfully."])
      end
    end

    # POST /event_orders
  #   def create
  #     event_order_params_tmp = event_order_params
  #     event_order_params_tmp[:user_id] = current_user.id
  #     @user_event_order = current_user.event_orders.find_by(:event_id => event_order_params_tmp[:event_id], :status => "cart")

  #     #order doesn't exist and needs to be created
  #     if @user_event_order.nil?
  #       @event_order = EventOrder.new(event_order_params_tmp)
  #       if @event_order.save
  #         render json: @event_order
  #       else
  #         render json: @event_order.errors, status: :unprocessable_entity
  #       end
  #     else
  #       render json: @user_event_order
  #     end
  #   end

    # PATCH/PUT /event_orders/1
    def update
      authorize @event_order
      if @event_order.update(event_order_update_params)
        render json: @event_order
      else
        render json: @event_order.errors, status: :unprocessable_entity
      end
    end

    # DELETE /event_orders/1
    def destroy
      authorize @event_order
      res = @event_order.destroy
      render json: res
    end

    def blessed_payment
      begin

        raise SyException, 'Invalid paramter, No category found' unless params[:event_order_id].present? and params[:category].present?

        @event_order = EventOrder.find_by(id: params[:event_order_id])

        raise SyException, 'No order found.' unless @event_order.present?

        raise SyException, 'Blessed payment are allowed in free event(s) and blessed category.' if @event_order.event.payment_category != 'free' and params[:category] == 'Blessed'

        raise SyException, 'Not authorize to perform this action' unless current_user.present? and (current_user.event_admin? or current_user.india_admin? or @event_order.event.creator_user_id == current_user.id) if @event_order.event.payment_category != 'free'


        if @event_order.event.payment_category == 'free'
          prefix = 'FREE'
        else
          prefix = 'BLS'
        end

        @transaction_id = prefix + '-' + SecureRandom.base64(8).to_s

        raise SyException 'Error occured while updating event order' unless @event_order.update_attributes(transaction_id: @transaction_id, status: 'success', payment_method: params[:category])

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

      @event_order.send_free_event_registration_confirmation if EventOrder.statuses['success'] == EventOrder.statuses[@event_order.status]

      if is_error
        error([result])
      else
        render json:  @event_order
      end
    end

    def locate_collection
      @event_orders = EventOrderPolicy::Scope.new(current_user, EventOrder.preloaded_data).resolve(filtering_params).page(params[:page]).per(params[:per_page])
    end


    def generate_csv
      begin
        event = Event.where(id: params[:event_id]).includes({ address: [:db_city, :db_state, :db_country]}).last
        raise SyException, 'Please specify the event.' unless event.present?

        raise SyException, 'Please input a valid format.' unless %w(csv excel).include?(params[:format])

        event_orders =  EventOrder.where(event_id: params[:event_id]).includes(
          :event_order_line_items, {sadhak_profiles: [{ address: [:db_city, :db_state, :db_country]}, {event_registrations: [:event]}, :events]},
          {event: [:event_seating_category_associations, :seating_categories, { address: [:db_city, :db_state, :db_country] }, {discount_plan: [:events]}]},
          :registration_center, :event_order_line_items, :user, :pg_cash_payment_transactions, :pg_sydd_transactions, :stripe_subscriptions, :pg_sy_razorpay_payments, :pg_sy_braintree_payments, :pg_sy_paypal_payments, :order_payment_informations).order(:created_at)

        event_order = event_orders.last

        raise 'You are not authorize to perform this action.' unless EventOrderPolicy.new(current_user, event_order).generate_csv?

        data = event_order.do_generate_event_orders_data(event_orders, event)

        if params['format'] == 'csv'
          blob = GenerateCsv.generate(data)
        elsif params['format'] == 'excel'
          params[:format] = 'xls'
          blob = GenerateExcel.generate(data)
        end

        if params[:email].present?
          begin
            from = GetSenderEmail.call(event)
            ApplicationMailer.send_email(from: from, recipients: params[:email], subject: "Applications for #{event.try(:event_name)}-#{event.try(:id)} Dated: #{DateTime.now.strftime('%F %T')}-#{DateTime.now.to_i}.", attachments: Hash["Applications_#{event.try(:id)}_#{event.try(:event_name)}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.#{params[:format]}", blob]).deliver
          rescue Exception => e
            Rails.logger.info("Some error ocuured while sending email: EventOrdersController #generate_csv, error: #{e.message}")
          end
        end
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
        is_error = true
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        message = e.message
        is_error = true
      end

      # Return json
      unless is_error
        send_data blob, :filename => "Applications_#{event.try(:id)}_#{event.try(:event_name)}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.#{params[:format]}"
      else
        error([message])
      end
    end

    def resend_transaction_receipt_email

      begin
        txns = []

        event_order = EventOrder.where(id: params[:event_order_id]).includes({event_order_line_items: [:event_registration, :sadhak_profile, {event_seating_category_association: [:seating_category]}]}, :sadhak_profiles, {event: { address: [:db_city, :db_state, :db_country] }}).last

        raise SyException, "Event order not found with id #{params[:event_order_id]}" unless event_order.present?

        email = params[:email] || event_order.guest_email

        TransferredEventOrder.gateways.each do |gateway|
          txns += (Object.const_get gateway[:model]).where(event_order_id: event_order.id, status: gateway[:success]).collect{|t| {amount: t[:amount], transaction_id: t[gateway[:transaction_id].to_s.to_sym], payment_method: gateway[:payment_method]}}
        end

        raise SyException, "Transaction(s) not found associated with reference number #{event_order.reg_ref_number}" if txns.size == 0

        total_transactions_amount = txns.collect {|t| t[:amount]}.sum.to_f

        # Get Syids
        syids = event_order.sadhak_profiles.collect{|s| s.syid}.join(',')

        # Get sender email
        from = GetSenderEmail.call(event_order.event)

        # Fire email only if event order success and payment success or payment method is dd and dd received by RC or Ashram or India Admin
        ApplicationMailer.send_email(from: from, recipients: email, template: 'resend_transaction_receipt_email', subject: "Duplicate Registration(s) Receipt ##{event_order.reg_ref_number} ##{syids} - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", txns: txns, total_transactions_amount: total_transactions_amount, event_order: event_order).deliver

      rescue SyException => e
        is_error = true
        message = e.message
      rescue => e
        is_error = true
        message = e.message
        Rollbar.error(e)
      end

      if is_error
        error([message], 'event_order')
      else
        success(["Transaction receipt emailed successfully on #{email}"], 'email')
      end
    end

    def create_new_forum_event_order(event_order_params, sy_club_id)
      # check if event_id and sadhak_profiles information is passed
      if event_order_params.has_key?('event_id') and event_order_params.has_key?('sadhak_profiles')
        flag = 0
        @event = Event.find_by_id(event_order_params[:event_id])
        @sy_club = SyClub.find_by_id(sy_club_id)
        if @event.present? and @event.is_club_event? and @sy_club.present?
          # event_type_pricing = EventTypePricing.find(event_type_pricing_id)
          # check if event found and status of event allows registrations
          if !@event.nil? && @event.is_club_event? #&& ( @event.status == 'test_registration' or @event.status == 'ready')
            if !current_user.nil? or (event_order_params.has_key?('guest_email') and !event_order_params[:guest_email].blank?)
              errors = []
              requested_event_type_pricing = []
              valid_profiles_to_register = []
              # seating_categories_requested = []
              event_order_params['sadhak_profiles'].each_with_index do |sp, i|
                # check if syid was passed with the sadhak details
                if sp.has_key?('syid')
                  sadhak_profile = SadhakProfile.find_by(:syid => sp['syid'])
                  # check if sadhak_profile is found by syid
                  if !sadhak_profile.nil?
                    #check if first name matches with the syid
                    if sp.has_key?('first_name') and sp['first_name'] == sadhak_profile.first_name
                      #check if sadhak already registered for the event
                      if !sadhak_profile.events.include?(@event) and @event.is_club_event?
                        sp[:id] = sadhak_profile.id
                        sp[:first_name] = sadhak_profile.first_name
                        scr = requested_event_type_pricing.find {|sc| sc[:id] == sp['event_type_pricing_id'] }
                        if scr.nil?
                          requested_event_type_pricing.push({:id => sp['event_type_pricing_id'], :sadhaks => [sadhak_profile.id]})
                        else
                          scr[:sadhaks].push(sadhak_profile.id)
                        end
                        valid_profiles_to_register.push(sp)
                      else
                        sp[:message] = "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid}"
                        sp['error'] = 'Sadhak Profile already registered for this event.'
                        errors.push(sp)
                      end

                    else
                      sp['error'] = 'syid does not match with the first name.'
                      errors.push(sp)
                    end
                  else
                    sp['error'] = 'Sadhak Profile not found.'
                    errors.push(sp)
                  end
                else
                  sp['error'] = 'SYID not specified'
                  errors.push(sp)
                end
              end

              #all sadhak profiles are valid to be added to event order line items
              if errors.count == 0
                requested_event_type_pricing_error = []
                requested_event_type_pricing.each do |scr|
                  event_type_pricing_model = EventTypePricing.find_by_id(scr[:id])
                  #check if EventTypePricing found`
                  if event_type_pricing_model.nil?
                    #check if EventTypePricing belongs to the requested event_type
                  # else
                    requested_event_type_pricing_error.push({:event_seating_category_association_id => scr[:id], :error => 'Event Pricing not found'})
                  end
                end
                if requested_event_type_pricing_error.count == 0
                  #all good, we can continue with the order create
                  #valid_profiles_to_register
                  if current_user
                    user_id = current_user.id
                    guest_email = event_order_params[:guest_email]
                  else
                    user_id = nil
                    guest_email = event_order_params[:guest_email]
                  end
                  event_order_hash = {event_id: @event.id, user_id: user_id, guest_email: guest_email, is_club_order: true, sy_club_id: sy_club_id}
                  @event_order = EventOrder.new(event_order_hash)
                  if params.has_key?(:rc_user) and params[:rc_user] == 1
                    @event_order.registration_center_user_id = @event.get_registration_center_user_id(current_user.id)
                  end
                  if @event_order.save
                    valid_profiles_to_register.each do |vp|
                      @event_type_pricing = EventTypePricing.find_by_id(vp[:event_type_pricing_id]) if vp[:event_type_pricing_id].present?
                      event_order_line_item_hash = {sadhak_profile_id: vp[:id], price: @event_type_pricing.price, event_type_pricing_id: @event_type_pricing.id,}
                      @event_order.event_order_line_items.create(event_order_line_item_hash)
                    end
                    return @event_order
                  else
                    render json: {error: 1, message: @event_order.errors }, status: :unprocessable_entity
                    return false
                  end
                else
                  error(['Price not defined'])
                end
              else
                error(errors, 'profile')
              end
            else
              error("Guest email cannot be empty for non-logged in user")
            end
          else
            error('Event is not a forum event')
          end
        else
          error("Event is not forum event or No Forum found with this forum_id: #{sy_club_id}", 'event_order')
        end
      else
        render json: {error: 1}, status: :unprocessable_entity
        return false
      end
    end

    def check_order
      if  event_order_params.has_key?('event_id') and event_order_params[:event_id].present? and event_order_params.has_key?('sadhak_profiles') and event_order_params[:sadhak_profiles].count > 0
        event = Event.includes(event_orders: [{event_order_line_items: :event_order}, :event_registrations]).find_by_id(event_order_params[:event_id])
        if !event.nil? && ( event.status == 'test_registration' or event.status == 'ready' or (current_user.present? and (current_user.super_admin or current_user.event_admin or SadhakProfile.new.verify_by_rc(current_user, event.id))))
          existing_sadhaks = []
          sadhak_profile_ids = event_order_params[:sadhak_profiles].collect{|sp| sp[:syid].scan(/\d/).join.to_i}
          event_order_ids = event.event_orders.order('created_at DESC').pluck(:id)
          existing_line_items = EventOrderLineItem.includes(:event_order).where(sadhak_profile_id: sadhak_profile_ids, event_order_id: event_order_ids, status: EventOrderLineItem.valid_line_item_statuses).order('created_at DESC').limit(1)
          if existing_line_items.count > 0
            existing_sadhaks = existing_line_items.collect{|item| {sadhak_profile_id: item.sadhak_profile_id, reg_ref_number: item.event_order.reg_ref_number, transaction_id: item.event_order.transaction_id, status: item.status}}
          end
          render json: existing_sadhaks
        else
          error(['Either event is not present or event is closed.'])
        end
      else
        error(['Parameters missing.'])
      end
    end

    def get_tax_details
      begin
        @event_order = EventOrder.preloaded_data.find_by_id(payment_detail_params[:event_order_id])
        raise SyException, "Please provide valid event order id." unless @event_order.present?
        result = @event_order.payble_amount_with_taxes(payment_detail_params)
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        is_error = true
        result = e.message
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        result = e.message
        is_error = true
      end
      # Send error to UI
      if is_error
        error([result])
      else
        render json: result
      end
    end

    # Method to allow registration changes before payment, only in case of pre_approval events.
    def edit_before_pay
      begin
        raise SyException, 'Sadhak Profiles are missing.' unless params[:sadhak_profiles].present?
        event_order = EventOrder.includes(:event_order_line_items, :event).find_by(id: params[:event_order_id])
        raise SyException, 'Event order not found.' unless event_order.present?
        raise SyException, 'Event must be pre approval.' unless event_order.event.pre_approval_required?
        raise SyException, 'Application should be already approve in order to make changes.' unless event_order.approve?

        # Authrization
        # raise 'You are not authroized to perform this action.' unless EventOrderPolicy.new(current_user, event_order).edit_before_pay?

        # Perfrom changes.
        event_order.update_before_pay(params[:sadhak_profiles])

      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        is_error = true
        result = e.message
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        result = e.message
        is_error = true
      end
      unless is_error
        success({}, ['have been updated successfully.'], 'Registration(s)')
      else
        error([result])
      end
    end

    def resend_pre_approval_email
      begin

        @event_order = EventOrder.find_by_reg_ref_number(params[:reg_ref_number])

        raise SyException, 'Please provide valid event order id.' unless @event_order.present?

        @event = @event_order.event

        # Authorize request if not an automatic refund
        raise 'You are not authorize to perform this action.' unless EventOrderPolicy.new(current_user, @event_order).resend_pre_approval_email?

        raise SyException, "Event: #{@event.event_name} is not configured as pre approval event." unless @event.pre_approval_required?

        raise SyException, 'No approver found to send email.' unless @event.approver_email.present?

        @event_order.pre_approval_application_details

        result = "Soon you will get email on #{@event.approver_email.to_s.split(',').to_sentence}."

      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        is_error = true
        result = e.message
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        result = e.message
        is_error = true
      end

      # Send error to UI
      if is_error
        error([result])
      else
        success({}, [result], 'Email Status: ')
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_order
        @event_order = EventOrder.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def event_order_params
        params.require(:event_order).permit! #(:event_id, :sadhak_profiles)
      end

      def event_order_update_params
        params.require(:event_order).permit(:status)
      end

      def filtering_params
        params.slice(:event_id, :registration_center_id, :reg_ref_number, :transaction_id, :payment_method, :first_name, :status).select { |key, value| value.present? }
      end

      def payment_detail_params
        params.require(:payment_details).permit!
      end

      def request_params
        params.require(:payment_refund).permit!#(:event_order_id, :method, :payment_method, :transaction_id, :reg_ref_number, :amount, :event_id, :sadhak_profiles)
      end

      def change_line_item_status_params
        params.require(:update_line_item).permit(:status, :event_order_id, :transferred_ref_number, :sadhak_profile_ids, :event_order_line_item_ids, :sadhak_profile_ids => [], :event_order_line_item_ids => [])
      end

      def registration_upgrades_params
        params.require(:registration_upgrade).permit!
      end

      def refund_email_params
        params.require(:data).permit!
      end

  end
end
