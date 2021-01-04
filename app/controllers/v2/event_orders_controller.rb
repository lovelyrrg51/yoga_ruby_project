module V2
  class EventOrdersController < BaseController
    include PaymentGatewayFormsHelper
    include EventOrdersHelper
    before_action :set_event_order, only: [:show, :pay, :registration_details, :confirmation_details, :cancel_registrations, :initiate_refund, :payment_refunds, :upgrade_downgrade, :process_event_order_confirmation, :process_event_order_details, :payment, :transfered_events, :edit_details, :hdfc_complete, :complete, :update_status, :resend_pre_approval_email, :resend_transaction_receipt_email, :pre_approval_complete, :payment_mode_details, :edit_before_pay, :edit_line_items, :registration_receipt]
    before_action :set_event, only: [:create, :payment_mode_details, :edit_before_pay, :edit_line_items]
    before_action :set_payment_mode_association, only: [:payment_mode_details]
    before_action :set_payment_gateway, only: [:payment_mode_details]
    before_action :find_event, only: [:registration_details, :confirmation_details, :cancel_registrations, :initiate_refund, :payment_refunds, :upgrade_downgrade, :process_event_order_confirmation, :process_event_order_details, :payment, :transfered_events, :edit_details]

    def show
      @event = @event_order.event

      raise 'No Sadhak Profile is registered on this Event Order.' if @event_order.event_order_line_items.blank?
      raise 'You are not allowed to access this page.' if @event.free?

      @is_registrations_allowed = is_event_running?(@event)
      @currency = @event.currency_code

      case
      when @event.pre_approval_required? && @event_order.rejected?
        flash[:notice] = 'Application is not accepted for this event.'
        redirect_to registration_details_v2_event_order_path(@event_order)
      when @event.pre_approval_required? && @event_order.pending?
        flash[:notice] = 'Application submitted for Approval.'
        redirect_to pre_approval_complete_v2_event_order_path(@event_order)
      when @event_order.success? || @event_order.dd_received_by_rc? || @event_order.dd_received_by_india_admin? || @event_order.dd_received_by_ashram?
        flash[:notice] = 'Payment is already received for this order.'
        redirect_to complete_v2_event_order_path(@event_order)
      end

      @event_order_line_items = @event_order.event_order_line_items
        .includes(:event_registration, :sadhak_profile, :event_seating_category_association)

      # vars for vue component
      @order_data = ui_payment_data(@event_order, @event)
    rescue => e
      flash[:alert] = e.message
      redirect_to v2_event_path(@event)
    end

    # POST /event_orders
    def create
      @event_order = @event.create_event_order(event_order_params.merge(current_user: current_user))

      if @event.pre_approval_required? && !@event.auto_approve?
        @event_order.delay.pre_approval_application_details
      end

      if @event_order.pending? && @event.pre_approval_required?
        if @event.auto_approve?
          # Mark approve and proceed for payment
          @event_order.update!(status: :approve)
          render json: {
            success: true,
            message: 'Event order was successfully created.'
          }.merge(ui_payment_data(@event_order, @event))
        else
          # Submitted for approval
          render json: {
            success: true,
            message: 'Application submitted for Approval.',
            redirect_path: pre_approval_complete_v2_event_order_path(@event_order),
            pre_approval: true
          }
        end
      elsif @event_order.pending? && @event.free?
        @event_order.update!(
          status: :success,
          transaction_id: "FREE-#{SecureRandom.base64(8).to_s}",
          payment_method: 'FREE'
        )
        render json: {
          success: true,
          message: 'You have successfully Registered on this event.',
          redirect_path: complete_v2_event_order_path(@event_order),
          free: true
        }
      else
        render json: {
          success: true,
          message: 'Event order was successfully created.'
        }.merge(ui_payment_data(@event_order, @event))
      end
    rescue StandardError => e
      Rollbar.error(e)
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def registration_status
    end

    def check_registration_exists
      event_order = EventOrder.find_by(reg_ref_number: params[:reg_ref_number])
      if event_order
        redirect_to registration_details_v2_event_order_path(event_order)
      else
        flash[:alert] = "Please Enter a valid Registration Reference Number."
        redirect_to registration_status_v2_event_orders_path
      end
    end

    def registration_details
      @is_event_running = is_event_running?(@event)
    end

    def confirmation_details
      @currency = @event.currency_code
      @gateway = TransferredEventOrder.gateways.find { |g| g[:payment_method] == @event_order.payment_method }
      @payment = @gateway[:model].try(:constantize).try(:where, { @gateway[:transaction_id] => @event_order.transaction_id, status: @gateway[:success] }).try(:last) if @gateway
      @event_order_line_items = @event_order.event_order_line_items.includes(:event_registration, :sadhak_profile, :event_seating_category_association)
    rescue StandardError => e
      Rollbar.error(e)
      flash[:alert] = e.message
      redirect_to event_event_order_path(@event, @event_order)
    end

    def cancel_registrations
      raise "Please select the valid Action." unless event_order_params[:action] && EVENT_ORDER_ACTIONS.values.include?(event_order_params[:action]) && event_order_params[:action] == EVENT_ORDER_ACTIONS[2]
      event_order_line_items = EventOrderLineItem.where(id: event_order_params[:event_order_line_item_ids])
      raise "Please select some sadhak profiles" unless event_order_line_items.present?
      sadhak_profiles = event_order_line_items.collect do |item|
        {
            syid: item.sadhak_profile_id.to_s,
            sadhak_profile_id: item.sadhak_profile_id.to_s,
            event_seating_category_association_id: item.event_seating_category_association_id,
            event_order_line_item_id: item.id
        }
      end
      requested_params = {
          sadhak_profiles: sadhak_profiles,
          event_id: @event_order.event_id,
          reg_ref_number: @event_order.reg_ref_number,
          event_order_id: @event_order.id,
          is_transfer: false,
          shifted_event_id: @event.id
      }
      @event_order.update_columns(gateway_redirect_url: requested_params.to_json.compress.encrypt)
      respond_to do |format|
        format.js { redirect_to initiate_refund_v2_event_order_path(@event_order), turbolinks: false }
      end
    rescue => e
      flash[:alert] = e.message
      redirect_to registration_details_v2_event_order_path(@event_order)
    end

    def initiate_refund
      @enc_request_params = @event_order.gateway_redirect_url
      @event_order.update_columns(gateway_redirect_url: nil)
      request_params = format_params(@enc_request_params)
      @event_order = EventOrder.includes(:event, :event_order_line_items).find_by_id(request_params[:event_order_id])
      find_form_event_order(@event_order, request_params, "initiate_refund")
      @event = @from_event_order.event
      @event_order_policy = EventOrderPolicy.new(current_user, @from_event_order)
      check_exception(request_params, @from_event_order, @event, @event_order_policy, @event_order, "initiate_refund")
      check_global_india_events(@downgraded, @event)
      calculate_cancellation_charges(@is_transfer, @downgraded, @db_refundable_amount, @event, @sadhak_profiles)
      calculate_paid_and_refundable_amount(@event_order)
      @net_amount = @db_refundable_amount - @cancellation_charges_by_policy
      request_params[:amount] = @net_amount
      @enc_request_params = request_params.to_json.compress.encrypt
    rescue => e
      Rollbar.error(e)
      flash[:alert] = e.message
    end

    def payment_refunds
      request_params = JSON.parse(payment_refunds_params).with_indifferent_access
      calculate_event_and_event_order(request_params)
      @event_order_policy = EventOrderPolicy.new(current_user, @from_event_order)
      check_exception(request_params, @from_event_order, @event, @event_order_policy, @event_order, "payment_refunds")
      check_global_india_events(@downgraded, @event)
      calculate_cancellation_charges(@is_transfer, @downgraded, @db_refundable_amount, @event, @sadhak_profiles)
      calculate_paid_and_refundable_amount(@from_event_order)
      find_action(request_params)
      create_cancellation_upgrade_transfer_request(request_params) # Create cancellation/upgrade/transfer request for each profile
      success_parameters(request_params) # Success parameters
      redirect_to registration_details_v2_event_order_path(@from_event_order)
    rescue StandardError => e
      Rollbar.error(e)
      flash[:alert] = e.message
      redirect_to registration_details_v2_event_order_path(@from_event_order)
    end

    def upgrade_downgrade
      redirect_to registration_details_v2_event_order_path(@event_order) and return if request.get?

      @event_order_line_items = EventOrderLineItem.where(id: params[:event_order][:event_order_line_item_ids])
      raise "Please select Sadhak Profiles." unless @event_order_line_items.present?
      raise "Please select the valid Action." unless params[:event_order][:action] && EVENT_ORDER_ACTIONS.values.include?(params[:event_order][:action])
      @action = params[:event_order][:action]
      @is_transfer = @event_order.event != @event
      raise "You cannot edit Sadhak Details for Transfered Pre approval Event." if @event.pre_approval_required? && @is_transfer
      raise "Please select the valid options." unless params[:event_order][:to_event_id] && params[:event_order][:to_event_id] == @event.slug && params[:event_order][:action] == EVENT_ORDER_ACTIONS[0] if @is_transfer

      # When user tries to edit/remove registered sadhak, then after completing profile, the final sadhak profile step page will redirect to cookies URL.
      cookies.encrypted[COMPLETE_PROFILE_REDIRECT_URL.encrypt] = registration_details_v2_event_order_path(@event_order)
    rescue StandardError => e
      Rollbar.error(e)
      flash[:error] = e.message
      redirect_back fallback_location: registration_details_v2_event_order_path(@event_order)
    end

    def transfered_events
      raise "No Sadhak Profile found. Please select the Sadhak Profiles." if params[:selected_line_items].blank?
      event_order_line_items = EventOrderLineItem.where(id: params[:selected_line_items]).includes(sadhak_profile: :events)
      raise "No Line Items found." if event_order_line_items.blank?
      scope = Event.where.not(pre_approval_required: true)
        .left_joins(:address, :event_type)
        .where(addresses: { country_id: @event.address.country_id })
        .where.not("event_types.name IN (?)", SHIVIRS_1K + [ASHRAM_RESIDENTIAL_SHIVIR])
      if current_user&.super_admin? || current_user&.india_admin? || current_user&.event_admin?
        @events = scope
      else
        ids = Event.upcoming.ids | Event.ongoing.ids
        @events = scope.where(events: { id: ids })
      end
    rescue StandardError => e
      Rollbar.error(e)
      flash[:alert] = e.message
    end

    def edit_details
      # If the same action (which is a POST) is reloaded, it will land it to the Registration status page.
      redirect_to registration_details_v2_event_order_path(@event_order) and return if request.get?

      @event_order_line_items = EventOrderLineItem.where(id: event_order_params[:event_order_line_item_ids])
      raise "Please select Sadhak Profiles." unless @event_order_line_items.present?
      raise "Please select the valid Action." unless event_order_params[:action] && EVENT_ORDER_ACTIONS.values.include?(event_order_params[:action])
      @action = event_order_params[:action]
      @is_transfer = @event_order.event != @event
      raise "You cannot edit Sadhak Details for Transfered Pre approval Event." if @event.pre_approval_required? && @is_transfer
      raise "Please select the valid options." unless event_order_params[:to_event_id] && event_order_params[:to_event_id] == @event.slug && event_order_params[:action] == EVENT_ORDER_ACTIONS[0] if @is_transfer
      # When user tries to edit/remove registered sadhak, then after completing profile, the final sadhak profile step page will redirect to cookies URL.
      cookies.encrypted[COMPLETE_PROFILE_REDIRECT_URL.encrypt] = registration_details_v2_event_order_path(@event_order)
    rescue StandardError => e
      Rollbar.error(e)
      flash[:alert] = e.message
      redirect_back fallback_location: registration_details_v2_event_order_path(@event_order)
    end

    def process_event_order_confirmation
      sadhak_profiles = event_order_params[:event_order_line_items_attributes].values
      raise "No edited profile found." unless sadhak_profiles.present?
      @payment_params = @event_order.pay_or_refund({ sadhak_profiles: sadhak_profiles, event_id: @event.id })
      raise "No Changes made in any of the Sahdak Profile." if @payment_params[:touched_event_order_line_items].blank?
      @before_sadhak_details = @payment_params[:old_details]
      raise "Old Sadhak Details not found." if @before_sadhak_details.blank?
      @after_sadhak_details = @payment_params[:new_details]
      raise "New Sadhak Details not found." if @after_sadhak_details.blank?
      @action = event_order_params[:action]
    rescue StandardError => e
      @message = e.message
      flash[:alert] = e.message
    end

    def process_event_order_details
      begin
        @is_transfer = @event_order.event != @event
        @new_event_order = @event_order
        @event_order_policy = EventOrderPolicy.new(current_user, @event_order)
        sadhak_profiles = event_order_params[:event_order_line_items_attributes].values
        raise "No edited profile found." unless sadhak_profiles.present?
        raise "Please select the valid Action." unless event_order_params[:action] && EVENT_ORDER_ACTIONS.values.include?(event_order_params[:action])
        @action = event_order_params[:action]
        @pay_or_refund = @event_order.pay_or_refund({ sadhak_profiles: sadhak_profiles, event_id: @event.id })
        raise "Online Registrations are closed at the moment for #{@event.try(:event_name)}." unless is_event_running?(@event)
        if @pay_or_refund[:refund]
          raise SyException, "Event registration has been closed. Please contact event organiser for cancellation/downgrade/transfer." unless (@event_order.event.event_start_date.present? and DateTime.now <= (@event_order.event.event_start_date - 2) || @event_order_policy.payment_refunds?)
        end
        event_order_params[:event_order_line_items_attributes].each do |key, value|
          event_order_params[:event_order_line_items_attributes].delete(key) unless @pay_or_refund[:touched_event_order_line_items].include?(value[:event_order_line_item_id].to_i)
        end
        if @is_transfer && (@event_order.event.automatic_refund? || @pay_or_refund[:pay])
          event_order_params[:guest_email] = @event_order.guest_email
          @new_event_order = @event.create_event_order(event_order_params.merge(current_user: current_user))
          TransferredEventOrder.create!(child_event_order_id: @new_event_order.id, parent_event_order_id: @event_order.id)
        end
        requested_params = {
            sadhak_profiles: event_order_params[:event_order_line_items_attributes].values.as_json.collect { |sp| sp.dup.merge({ syid: sp['sadhak_profile_id'] }) },
            event_id: @event_order.event_id,
            reg_ref_number: @event_order.reg_ref_number,
            event_order_id: @new_event_order.id,
            is_transfer: @is_transfer,
            shifted_event_id: @event.id
        }
        @new_event_order.update_columns(gateway_redirect_url: requested_params.to_json.compress.encrypt)
        if @pay_or_refund[:pay]
          respond_to do |format|
            format.js { redirect_to payment_v2_event_order_path(@new_event_order), turbolinks: false }
          end
        elsif @pay_or_refund[:refund]
          respond_to do |format|
            format.js { redirect_to initiate_refund_v2_event_order_path(@new_event_order), turbolinks: false }
          end
        else
          raise 'Invalid decision.'
        end
      rescue Exception => e
        flash[:alert] = e.message
        redirect_to registration_details_v2_event_order_path(@event_order)
      end
    end

    def payment
      begin
        begin
          request_params = JSON.parse(@event_order.gateway_redirect_url.decrypt.decompress).with_indifferent_access
        rescue => e
          flash[:alert] = "Invalid Request. Parameters missing."
          redirect_to registration_status_v2_event_orders_path
          return
        end
        @event_order.update_columns(gateway_redirect_url: nil)
        @payment_params = @event_order.pay_or_refund({ sadhak_profiles: request_params[:sadhak_profiles], event_id: @event.id })
        @is_registrations_allowed = is_event_running?(@event)
        raise "You cannot make payments for free events." if @event.free?
        @before_event_order_line_items = request_params[:sadhak_profiles].pluck(:event_order_line_item_id)
        raise "No Event Order Line Items found." if @before_event_order_line_items.blank?
        @parent_event_order_id = EventOrder.find_by_reg_ref_number(request_params[:reg_ref_number]).try(:id)
        raise "No Event Order found." if @parent_event_order_id.blank?

        @upgrade = true

        @before_sadhak_details = @payment_params[:old_details]
        raise "Old Sadhak Details not found." if @before_sadhak_details.blank?

        @after_sadhak_details = @payment_params[:new_details]
        raise "New Sadhak Details not found." if @after_sadhak_details.blank?

        @sadhak_details_hash = request_params
        raise "Invalid amount found." unless @payment_params[:net_result] && @payment_params[:net_result].positive?

        @net_amount = @payment_params[:net_result]

        @tax_details = @event.calculate_tax_amount({ original_amount: (@payment_params[:total_new_price] - @payment_params[:total_old_price]).rnd, total_discount: (@payment_params[:total_new_discount] - @payment_params[:total_old_discount]).rnd })
      rescue => e
        flash[:alert] = e.message
      end
    end

    def pay
      @event = @event_order.event
      dec_payment_details = JSON.parse(params[ENCRYPT_PAYMENT_DETAILS_KEY.encrypt.to_sym].decrypt)
      find_upgrade(dec_payment_details)
      unless @event_order.guest_email.present?
        @event_order.update_column('guest_email', 'syitemails@gmail.com') # Added logic to overcome guest email issue.
      end
      # Assign some values used in gateways
      payment_detail_params[:guest_email] = @event_order.guest_email
      payment_detail_params[:pay_in_usd] = @event_order.event.pay_in_usd
      payment_detail_params[:gateway] = @gateway
      push_gateway_details(payment_detail_params, dec_payment_details) # Push gateway details to params: payment_detail_params

    rescue StandardError => e
      message = e.message
      Rails.logger.info(message)

      flash[:alert] = message if request.format != 'application/json'
      if @event_order.sy_club
        respond_to do |format|
          format.json {
            render json: { error: message }
          }
          format.html { redirect_to payment_sy_club_path(@event_order) }
        end
      elsif @upgrade.is_a?(TrueClass)
        respond_to do |format|
          format.json {
            render json: { error: message, redirect_path: registration_details_v2_event_order_path(@event_order) }
          }
          format.html { redirect_to registration_details_v2_event_order_path(@event_order) }
        end
      else
        respond_to do |format|
          format.json {
            render json: { error: message }
          }
          format.html { redirect_to v2_event_path(@event) }
        end
      end
    end

    def edit_line_items
      redirect_to event_event_order_path(@event, @event_order) and return if request.get?

      raise "Provided Event is not a Pre Approval Event." unless @event.pre_approval_required
      raise 'Application should be approve in order to make changes.' unless @event_order.approve?
      @event_order_line_items = EventOrderLineItem.where(id: event_order_params[:event_order_line_item_ids])
      raise "No Sadhak Profile is selected." unless @event_order_line_items.present?
    rescue StandardError => e
      Rollbar.error(e)
      flash[:alert] = e.message
      redirect_back fallback_location: event_event_order_path(@event, @event_order)
    end

    def edit_before_pay
      raise 'Application should be already approve in order to make changes.' unless @event_order.approve?
      @sadhak_profiles = event_order_params[:event_order_line_items_attributes].values
      raise 'Sadhak Profiles are missing.' unless @sadhak_profiles.present?
      # Authrization
      # raise 'You are not authroized to perform this action.' unless EventOrderPolicy.new(current_user, event_order).edit_before_pay?
      # Perfrom changes.
      @sadhak_profiles.each { |sp| sp[:syid] = sp[:sadhak_profile_id] }
      is_sadhak_profile_touched = @event_order.update_before_pay(@sadhak_profiles.as_json.map(&:with_indifferent_access))
      if is_sadhak_profile_touched
        flash[:notice] = 'Application submitted for Approval.'
        redirect_to pre_approval_complete_v2_event_order_path(@event_order)
      else
        redirect_to event_event_order_path(@event, @event_order)
      end
    rescue StandardError => e
      Rollbar.error(e)
      logger.info(e.backtrace.inspect)
      flash[:alert] = e.message
      redirect_back fallback_location: root_path
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_event_order
      @event_order = EventOrder.find(params[:id])
    end

    def find_event
      @event = @event_order.event
    end

    # Only allow a trusted parameter "white list" through.
    def event_order_params
      params.require(:event_order).permit!
    end

    def payment_detail_params
      params.require(:payment_details).permit!
    end

    def bulk_update_event_order_status_params
      params.require(:event_order).permit(:status, :event_order_ids)
    end

    def set_event
      @event = Event.find(params[:event_id])
    end

    def set_payment_mode_association
      @payment_mode_association = PaymentGatewayModeAssociation.find_by_id(params[:payment_gateway_mode_association_id])
    end

    def set_payment_gateway
      @payment_gateway = @payment_mode_association.payment_gateway
    end

    def payment_refunds_params
      p = params.require(:event_orders).permit(PAYMENT_REFUND_PARAMS.encrypt.to_sym)
      p[PAYMENT_REFUND_PARAMS.encrypt.to_sym].decrypt.decompress
    end

    def format_params(enc_request_params)
      request_params = JSON.parse(enc_request_params.decrypt.decompress).with_indifferent_access
    rescue => e
      flash[:error] = "Invalid Request. Parameters missing."
      redirect_to registration_status_v2_event_orders_path
      return
    end

    def find_form_event_order(event_order, request_params, from)
      raise SyException, "Event order not found." unless event_order.present?
      @from_event_order = EventOrder.includes(:event).find_by_reg_ref_number(request_params[:reg_ref_number])
      raise SyException, "Event order is not found with reg_ref_number: #{request_params[:reg_ref_number]}." unless @from_event_order.present?
      if from == "payment_refunds"
        @from_event_order.pay_or_refund({ sadhak_profiles: request_params[:sadhak_profiles], event_id: request_params[:shifted_event_id] })
      else
        @pay_or_refund = event_order.pay_or_refund({ sadhak_profiles: request_params[:sadhak_profiles], event_id: request_params[:shifted_event_id] })
      end
    end

    def check_exception(request_params, from_event_order, event, event_order_policy, event_order, from)
      raise SyException, "We are unable to process your request as payment status is pending or demand draft is not reached to Ashram." unless ["success", "dd_received_by_ashram"].include?(from_event_order.status)

      @sadhak_profiles = request_params[:sadhak_profiles]
      raise SyException, "Please provide sadhak profiles." unless @sadhak_profiles.present?

      # Event has been closed. Allowed to super admin and event admin anytime
      raise SyException, "Event registration has been closed. Please contact event organiser for cancellation/downgrade/transfer." unless (event.event_start_date.present? and DateTime.now <= (event.event_start_date - 2) || event_order_policy.payment_refunds?)

      # Block payment refund for particular 1k type shivir(s)
      raise 'Refund is not allowed for 1k type shivir(s).' unless event_order_policy.can_refund_1k_shivir?
      if (from == "payment_refunds")
        @ui_amount = request_params[:amount].to_f.round(2) # Check for ui amount
        raise SyException, "Please input valid amount." if [nil, "", "NULL", "nil"].include?(@ui_amount)
      end
      compute_downgraded_and_transfer(event_order, request_params, @event) # Compute is_downgraded, details, is_tranfer and refundable amount
    end

    def compute_downgraded_and_transfer(event_order, request_params, event)
      @downgraded = event_order.compute_info(request_params)
      # Compute wether it is transfer case or not
      @is_transfer = @downgraded[:is_transfer]
      # Declare some variable if transfer case
      if @is_transfer
        if event.automatic_refund?
          @to_event = event_order.event
        else
          # Set shifted event
          @to_event = Event.find_by_id(request_params[:shifted_event_id])
        end
        raise SyException, "Transferred event not found." unless @to_event.present?
        # Check and set parameter is_transfer
        raise SyException, "This is transfer case but UI parameters is not matching." if request_params[:is_transfer] != @is_transfer
        request_params[:is_transfer] = @is_transfer
      end
    end

    def check_global_india_events(downgraded, event)
      # To block cancellation/upgrade/downgrade of registration if event is global or india clp events.
      @clp_event_ids = (GlobalPreference.get_value_of('india_clp_events').to_s.split(',') + GlobalPreference.get_value_of('global_clp_events').to_s.split(',')).map { |id| id.to_i }
      # Assign API calculated refundable amount
      @db_refundable_amount = downgraded[:amount]
      # Authorize request if not an automatic refund
      raise 'You need to sign in or sign up before continuing.' unless current_user.present? unless event.automatic_refund?
    end

    def calculate_cancellation_charges(is_transfer, downgraded, db_refundable_amount, event, sadhak_profiles)
      # Cancellation charges using cancellation policy
      if is_transfer or downgraded[:is_downgraded] or db_refundable_amount.zero?
        @cancellation_charges_by_policy = 0.0
      else
        @cancellation_charges_by_policy = event.cancellation_charges_by_policy(sadhak_profiles.collect { |sp| sp[:event_order_line_item_id] })
      end
    end

    def calculate_paid_and_refundable_amount(event_order)
      # Compute api side transactions and total paid amount and refundable amount
      @txn_details = TransferredEventOrder.get_txn_details(event_order.id)
      db_paid_amount = @txn_details.collect { |t| t[:total_paid_amount] }.sum.to_f.round(2)

      # Raise error if any error while getting transaction details
      raise SyException, TransferredEventOrder.get_refund_errors.first unless TransferredEventOrder.get_refund_errors.empty?
      # Collect all payment methods for event order by which payment is made
      event_order_payment_methods = (@txn_details || []).collect { |t| t[:payment_method] }
      check_payment_method_exception(@event, event_order_payment_methods, @db_refundable_amount, @cancellation_charges_by_policy, db_paid_amount)
    end

    def check_payment_method_exception(event, event_order_payment_methods, db_refundable_amount, cancellation_charges_by_policy, db_paid_amount)
      raise SyException, 'You are not allowed to make direct refund as it is not supported by payment gateway. Need help, Please contact shivir organisers.' if event.automatic_refund? and (event_order_payment_methods.include?('Ccavenue Payment') or event_order_payment_methods.include?('Payfast Payment') or event_order_payment_methods.include?('Hdfc Payment'))
      if @ui_amount.present?
        raise SyException, "You cannot make refund because available amount #{db_paid_amount} is lesser than requested amount #{@ui_amount}, cancellation charges: #{cancellation_charges_by_policy}." if db_paid_amount < (@ui_amount + cancellation_charges_by_policy)
        raise SyException, "You cannot make refund because requested amount doesn't match." unless db_refundable_amount == @ui_amount + cancellation_charges_by_policy
      else
        raise SyException, "You cannot make refund because available amount #{db_paid_amount} is lesser than requested amount #{db_refundable_amount - cancellation_charges_by_policy}, cancellation charges: #{cancellation_charges_by_policy}." if db_paid_amount < (db_refundable_amount - cancellation_charges_by_policy)
      end
    end

    def calculate_event_and_event_order(request_params)
      @event = Event.includes({ event_cancellation_plan: [:event_cancellation_plan_items] }).find_by_id(request_params[:event_id])
      raise SyException, "Event not found." unless @event.present?
      @event_order = EventOrder.includes(:event, :event_order_line_items).find_by_id(request_params[:event_order_id])
      find_form_event_order(@event_order, request_params, "payment_refunds")
    end

    def find_action(request_params)
      # Action
      @action = if @is_transfer and @downgraded[:is_downgraded] then
                  PaymentRefund.actions['transfer_downgrade']
                else
                  if @downgraded[:is_downgraded] then
                    PaymentRefund.actions['downgrade']
                  else
                    if @is_transfer then
                      PaymentRefund.actions['transfer']
                    else
                      @db_refundable_amount == 0 ? PaymentRefund.actions['update_record'] : PaymentRefund.actions['cancellation']
                    end
                  end
                end
      check_authorization_for_refund(@action, request_params)
    end

    def check_authorization_for_refund(action, request_params)
      if (@clp_event_ids.include?(@event.id) or @clp_event_ids.include?(@to_event.try(:id)))
        raise SyException, 'Category, Shivir and Name Change action(s) are not allowed on CLP.' if PaymentRefund.actions['cancellation'] != action
        # Authorize request. Allowed: Superadmin, event admin and india admin
        raise 'You are not authorized to perform this action.' unless @event_order_policy.clp_refund?
        raise 'Renewed/Expired membership(s) are not allowed to refund.' if (request_params[:details].collect { |d| d[:old_item_status] } & EventRegistration.statuses.slice(:expired, :renewed, :cancelled, :transferred, :cancelled_refunded, :shivir_changed).keys).size > 0
      end
      check_sadhak_joined_to_event(request_params)
    end

    def check_sadhak_joined_to_event(request_params)
      # Perform check that sadhak already joined to this event
      db_sadhaks = SadhakProfile.includes(:events).where(id: @sadhak_profiles.collect { |sp| sp[:syid] })
      # Iterate over each sadhak profile
      request_params[:details].each do |sp|
        sadhak = db_sadhaks.find { |s| s.id == sp[:syid].to_i }
        raise SyException, "Sadhak Profile with SYID: #{sp[:syid]} does not found in database." unless sadhak.present?
        if @is_transfer and not @event.automatic_refund?
          raise SyException, "SYID: #{sadhak.try(:syid)} Name: #{sadhak.try(:full_name)} is already registered to event: #{@to_event.try(:event_name)}." if sadhak.event_ids.include?(@to_event.id) # If sadhak changing shivir and manual mode of refund
        else
          raise SyException, "SYID: #{sadhak.try(:syid)} Name: #{sadhak.try(:full_name)} is already registered to event: #{@event.try(:event_name)}." if (sp[:touched_columns] || []).include?("sadhak_profile_id") and sadhak.event_ids.include?(@event.id)
        end
        if (@is_transfer and not @event.automatic_refund?) or (sp[:touched_columns] || []).include?("sadhak_profile_id")
          raise SyException, "SYID: #{sadhak.try(:syid)} Name: #{sadhak.try(:full_name)} is banned." if sadhak.banned? # To check wether sadhak profile is banned or not
        end
      end
    end

    def create_cancellation_upgrade_transfer_request(request_params)
      ActiveRecord::Base.transaction do
        raise SyException, "Not a valid action." unless PaymentRefund.actions.values.include?(@action)
        create_payment_refund(request_params) # Create payment refund request
        # Iterate over each sadhak profile details to create request
        request_params[:details].each do |sp|
          # If it is transfer case then assign transferred to event id to payment line items
          if [PaymentRefund.actions["transfer_downgrade"], PaymentRefund.actions["transfer"]].include?(@action)
            event_id = @to_event.id
          end
          create_payment_refund_line_item(event_id, sp) # Create payment refund request
        end
        @payment_refund.update_intermediate_line_item_status # Update intermediate status
        raise SyException, @payment_refund.errors.full_messages.first unless @payment_refund.errors.empty?
      end
    end

    def create_payment_refund(request_params)
      @payment_refund = PaymentRefund.new(event_order_id: @from_event_order.id, event_id: @event.id, action: @action, request_object: request_params, max_refundable_amount: @db_refundable_amount, event_cancellation_plan_id: @event.event_cancellation_plan_id, cancellation_charges: @cancellation_charges_by_policy, policy_refundable_amount: (@db_refundable_amount - @cancellation_charges_by_policy), shifted_event_order_id: (@is_transfer and @event.automatic_refund?) ? @event_order.id : nil)
      raise SyException, @payment_refund.errors.full_messages.first unless @payment_refund.save
    end

    def create_payment_refund_line_item(event_id, sp)
      payment_refund_line_item = PaymentRefundLineItem.new(sadhak_profile_id: sp[:syid], event_id: event_id, event_registration_id: sp[:event_registration_id], event_seating_category_association_id: sp[:event_seating_category_association_id], payment_refund_id: @payment_refund.id, event_order_line_item_id: sp[:event_order_line_item_id], old_item_status: sp[:old_item_status])
      raise SyException, payment_refund_line_item.errors.full_messages.first unless payment_refund_line_item.save
    end

    def success_parameters(request_params)
      message = "Your request has been initiated. Please use your registration reference number-#{@event_order.try(:reg_ref_number)} to track request status."
      refunds = nil
      db_refunded_amount = 0.0
      partial_refund = nil
      refund_other_details = request_params.except(:details).clone
      instant_refund(request_params, refunds, db_refunded_amount, partial_refund, refund_other_details) # If automatic refund is true means do instant refund else place request
    end

    def instant_refund(request_params, refunds, db_refunded_amount, partial_refund, refund_other_details)
      if @event.automatic_refund?
        if @ui_amount > 0.0
          set_refund_other_details(request_params, refund_other_details) # Set refund other details that is needed in transaction log
        end
        update_refunded_amount(db_refunded_amount, refund_other_details, request_params, refunds, partial_refund)
      end
    rescue => e
      rescue_sy_exception
      raise e.class, e.message
    end

    def set_refund_other_details(request_params, refund_other_details)
      refund_other_details[:is_downgraded] = @downgraded[:is_downgraded]
      refund_other_details[:db_refundable_amount] = @db_refundable_amount
      refund_other_details[:action] = PaymentRefund.actions.key(@action)
      refund_other_details[:payment_refund_id] = @payment_refund.id
      process_refund(refund_other_details, request_params)
    end

    def process_refund(refund_other_details, request_params)
      refund_details = TransferredEventOrder.process_refund(@txn_details, @ui_amount, refund_other_details)
      db_refunded_amount = refund_details[:db_refunded_amount]
      refunds = refund_details[:refunds]
      check_db_refunded_amount(db_refunded_amount, refund_other_details, refunds, request_params)
    end

    def check_db_refunded_amount(db_refunded_amount, refund_other_details, refunds, request_params)
      if db_refunded_amount > 0.0
        compare_db_refunded_and_ui_amount(db_refunded_amount, refund_other_details, refunds, request_params)
      elsif TransferredEventOrder.get_refund_errors.any?
        raise SyException, TransferredEventOrder.get_refund_errors.first
      else
        raise SyException, 'Something went wrong while processing your refund.'
      end
    end

    def compare_db_refunded_and_ui_amount(db_refunded_amount, refund_other_details, refunds, request_params)
      if db_refunded_amount == @ui_amount
        @message = "We have successfully processed your refund. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding refunds.' : ''}"
        partial_refund = false
      else
        @message = "Due to some internal error, We could not processed full refund. Sorry for the inconvenience happend to you. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding partial refund.' : ''} For remaining refund, Please contact to the Ashram."
        partial_refund = true
      end
      update_request_object(refund_other_details, db_refunded_amount, refunds, partial_refund, request_params) # Update request object and attach what has been refunded.
    end

    def update_request_object(refund_other_details, db_refunded_amount, refunds, partial_refund, request_params)
      refund_other_details[:total_refunded_amount] = db_refunded_amount
      refund_other_details[:refunds] = refunds
      refund_other_details[:partial_refund] = partial_refund
      refund_other_details[:errors] = @payment_refund.errors.full_messages # Update request object with errors
    end

    def update_refunded_amount(db_refunded_amount, refund_other_details, request_params, refunds, partial_refund)
      @payment_refund.errors.clear # Clear all errors as request completed
      # Update refunded amount and status and push errors to db if any while updation
      @payment_refund.update(amount_refunded: db_refunded_amount, status: @payment_refund.class.statuses["refunded"], request_object: refund_other_details.deep_merge(request_params))
      @payment_refund.perform_updation # Update registrations and line items
      @message = "We have successfully processed your request. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding your request.' : ''}"
      @payment_refund.reload.refund_email({ refunds: refunds, total_refunded_amount: db_refunded_amount, partial_refund: partial_refund }) if @payment_refund.event.try(:notification_service) # send refund email
      update_event_order
    end

    def update_event_order
      if @is_transfer
        @event_order.update(status: 'success', transaction_id: "TRANSFER_FROM-#{@from_event_order.reg_ref_number}-#{SecureRandom.base64(8).to_s}", payment_method: 'No Payment')
        @event_order.reload.notify_joining if @event_order.try(:event).try(:notification_service)
      end
    end

    def rescue_sy_exception
      @payment_refund.update_intermediate_line_item_status(true) # Delete captured payment refund requeste to allow user to place request again and restore line items updated status
      @payment_refund.update(is_deleted: true)
      Rails.logger.info("EventOrdersController, payment_refunds: errors while restroing line items and event registrations statuses: #{@payment_refund.errors.full_messages}") unless @payment_refund.errors.empty?
    end

    def find_upgrade(dec_payment_details)
      @upgrade = dec_payment_details['upgrade']
      raise "Event Order not found." unless @parent_event_order = EventOrder.find_by_id(dec_payment_details['parent_event_order_id']) if dec_payment_details['upgrade'].is_a?(TrueClass)
      if dec_payment_details.key?(:payment_gateway_mode_association_id)
        raise SyException, 'Provided Data: Payment Mode Id is Mismatched.' if dec_payment_details['payment_gateway_mode_association_id'].to_i != payment_detail_params[:payment_gateway_mode_association_id].to_i
      end
      check_payment_exception(dec_payment_details)
    end

    def check_payment_exception(dec_payment_details)
      raise SyException, 'Provided Data: Amount is Mismatched.' unless payment_detail_params[:amount].rnd == dec_payment_details['amount'].rnd
      raise SyException, 'Provided Data: Event Order Id is Mismatched.' unless payment_detail_params[:event_order_id].to_i == dec_payment_details['event_order_id'].to_i
      raise SyException, 'Provided Data: Payment Date is Mismatched.' unless payment_detail_params[:payment_date] == dec_payment_details['payment_date']
      raise SyException, 'Provided Data: Config Id is Mismatched.' unless payment_detail_params[:config_id] == dec_payment_details['config_id']
      raise SyException, 'Provided Data: Payment Method is Mismatched.' unless params[:method] == dec_payment_details['method']
      raise SyException, 'Provided Data: Parent Event Order Id is Mismatched.' unless payment_detail_params[:parent_event_order_id].to_i == dec_payment_details['parent_event_order_id'].to_i
      raise SyException, 'Provided Data: Action Upgrade is Mismatched.' unless payment_detail_params[:upgrade].to_s == dec_payment_details['upgrade'].to_s
      find_event_order_and_gateway(dec_payment_details)
    end

    def find_event_order_and_gateway(dec_payment_details)
      @gateway = TransferredEventOrder.gateways.find { |g| g[:symbol] == params[:method] }
      raise SyException, 'Please provide a valid payment method.' unless @gateway.present?

      @event_order = EventOrder.preloaded_data.find_by_id(payment_detail_params[:event_order_id])
      raise SyException, 'Please provide valid event order id.' unless @event_order.present?

      # Order status must be approve or pending
      raise SyException, 'Payment is already made against this order.' if @event_order.success? || @event_order.dd_received_by_rc? || @event_order.dd_received_by_india_admin? || @event_order.dd_received_by_ashram? if dec_payment_details['upgrade'].is_a?(FalseClass)

      raise "Application is not accepted for this event." if @event.pre_approval_required? && @event_order.rejected?

      raise "Application submitted for Approval." if @event.pre_approval_required? && @event_order.pending?
      check_event
    end

    def check_event
      is_event_running = (@event.end_date_ignored? || (@event.event_end_date.present? && Date.today <= @event.event_end_date))
      is_admin = (current_user.present? and (current_user.super_admin? or current_user.event_admin? or current_user.india_admin?))
      is_rc = current_user.try(:rc?, @event)
      raise SyException, 'Event is closed.' unless (is_event_running || is_admin || is_rc)
      raise SyException, 'Event is not ready for registrations.' unless (@event.status == 'test_registration' || @event.status == 'ready' || is_admin || is_rc)
    end

    def push_gateway_details(payment_detail_params, dec_payment_details)
      if dec_payment_details['upgrade'].is_a?(TrueClass)
        #set payment_detail_params need for verify amount
        payment_detail_params[:event_order_line_item_ids] = JSON.parse(params[EVENT_ORDER_LINE_ITEM_IDS.encrypt.to_sym].decrypt)
        raise "Event Order Line Items from params." if payment_detail_params[:event_order_line_item_ids].blank?
        payment_detail_params[:sadhak_profiles] = JSON.parse(params[SADHAK_PROFILE_DETAILS.encrypt.to_sym].decrypt).with_indifferent_access[:sadhak_profiles]
        raise "No sadhak details found from params." if payment_detail_params[:sadhak_profiles].blank?
        @hdfc_registration_payment_summary = @event_order.tax_details_for_upgrade({ sadhak_profiles: payment_detail_params[:sadhak_profiles] })
      elsif dec_payment_details['upgrade'].is_a?(FalseClass)
        payment_detail_params[:event_order_line_item_ids] = @event_order.event_order_line_item_ids
        payment_detail_params[:sadhak_profiles] = @event_order.event_order_line_items.collect { |i| { syid: i.sadhak_profile_id.to_s, first_name: i.sadhak_profile.first_name, event_seating_category_association_id: i.event_seating_category_association_id.to_s, event_order_line_item_id: i.id.to_s } }
        @hdfc_registration_payment_summary = registration_payment_summary(@event_order.event_order_line_items)
      else
        raise "Provided information is not appropriate." # raise exception if upgrade attribute is not true or false, if this exception raises means there is some changes from inspect.
      end
      verify_ui_amount(payment_detail_params)
    end

    def verify_ui_amount(payment_detail_params)
      raise SyException, 'Invalid payable amount.' unless @event_order.is_amount_valid?(payment_detail_params)
      case params[:method]
      when 'sydd'
        demand_draft_payment
      when 'ccavenue'
        ccavenue_payment
      when 'cash'
        cash_payment
      when 'stripe'
        stripe_payment
      when 'payfast'
        payfast_payment
      when 'hdfc'
        hdfc_payment
      end
    end

    def cash_payment
      find_gatway_and_transaction_log
      cash_payment, message = PgCashPaymentTransaction.create_payment(payment_detail_params.as_json.with_indifferent_access, @transaction_log)
      raise SyException, message if message.present?
      begin
        # Update event order line items and event registrations as payment completed.
        cash_payment.event_order.perform_updation(payment_detail_params[:details].as_json.map(&:with_indifferent_access))
      rescue => e
        Rollbar.error(e)
      end
      # Send joining email
      cash_payment.event_order.reload.notify_joining if cash_payment.try(:event_order).try(:event).try(:notification_service)
      respond_to do |format|
        format.json {
          render json: {
              success: 'Payment received successfully.',
              redirect_path: @event_order.sy_club ? complete_v2_forum_path(@event_order) : complete_v2_event_order_path(@event_order)
          }
        }
        format.html {
          flash[:success] = 'Payment received successfully.'
          redirect_to registration_status_v2_event_orders_path
        }
      end
    end

    def demand_draft_payment
      find_gatway_and_transaction_log
      dd, message = PgSyddTransaction.create_payment(payment_detail_params.as_json.with_indifferent_access, @transaction_log)
      raise SyException, message if message.present?
      dd.update(status: @gateway[:success])
      begin
        # Update event order line items and event registrations as payment completed.
        dd.event_order.perform_updation(payment_detail_params[:details].as_json.map(&:with_indifferent_access)) if EventOrder.statuses.slice(:dd_received_by_ashram, :dd_received_by_india_admin, :dd_received_by_rc, :success).values.include?(EventOrder.statuses[dd.event_order.reload.status])
      rescue => e
        Rollbar.error(e)
      end

      respond_to do |format|
        format.json {
          render json: {
              success: 'Payment received successfully.',
              redirect_path: @event_order.sy_club ? complete_v2_forum_path(@event_order) : complete_v2_event_order_path(@event_order)
          }
        }
        format.html {
          flash[:success] = 'Payment received successfully.'
          redirect_to @event_order.sy_club ? complete_v2_forum_path(@event_order) : registration_status_v2_event_orders_path
        }
      end
    end

    def stripe_payment
      find_gatway_and_transaction_log
      payment, message = StripeSubscription.create_payment(payment_detail_params.as_json.with_indifferent_access, @transaction_log)
      raise SyException, message if message.present?
      payment.event_order.update_attributes(transaction_id: payment.card, payment_method: 'Stripe Payment', status: payment.status)
      begin
        # Update event order line items and event registrations as payment completed.
        payment.event_order.perform_updation(payment_detail_params[:details].as_json.map(&:with_indifferent_access))
      rescue => e
        Rollbar.error(e)
      end
      # Send joining email
      payment.event_order.reload.notify_joining if payment.try(:event_order).try(:event).try(:notification_service)

      respond_to do |format|
        format.json {
          render json: {
              success: 'Payment received successfully.',
              redirect_path: @event_order.sy_club ? complete_v2_forum_path(@event_order) : complete_v2_event_order_path(@event_order)
          }
        }
        format.html {
          flash[:success] = 'Payment received successfully.'
          redirect_to registration_status_v2_event_orders_path
        }
      end
    end

    def ccavenue_payment
      gateway = TransferredEventOrder.gateways.find { |g| g[:symbol] == params[:method] }
      transaction_log = TransactionLog.create(gateway_request_object: payment_detail_params.except(:details), transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params.as_json.with_indifferent_access)
      # Set redirect and cancel URI
      app_base_url = Rails.application.config.app_base_url
      app_base_url = "http://shivyog-rails-fullview.herokuapp.com" if Rails.env.development?
      payment_detail_params[:redirect_url] = "#{app_base_url}#{success_v2_order_payment_informations_path}"
      payment_detail_params[:cancel_url] = "#{app_base_url}#{cancel_v2_order_payment_informations_path}"
      url_params = gateway.model.constantize.create_ccavenue_payment(payment_detail_params.as_json.with_indifferent_access, transaction_log)

      respond_to do |format|
        format.json {
          render json: {
              success: 'Redirect to ccavenue gateway',
              redirect_path: redirect_v2_order_payment_informations_path(url_params)
          }
        }
        format.html { redirect_to redirect_v2_order_payment_informations_path(url_params) }
      end
    end

    def hdfc_payment
      gateway = TransferredEventOrder.gateways.find { |g| g[:symbol] == params[:method] }
      transaction_log = TransactionLog.create(gateway_request_object: payment_detail_params.except(:details), transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params.merge({ registration_payment_summary: get_reg_payment_summary_object(@hdfc_registration_payment_summary) })), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params.as_json.with_indifferent_access)
      # Set redirect and cancel URI
      app_base_url = Rails.application.config.app_base_url
      app_base_url = "http://shivyog-rails-fullview.herokuapp.com" if Rails.env.development?
      payment_detail_params[:redirect_url] = "#{app_base_url}#{success_v2_pg_sy_hdfc_payments_path}"
      payment_detail_params[:cancel_url] = "#{app_base_url}#{cancel_v2_pg_sy_hdfc_payments_path}"
      url_params = gateway.model.constantize.create_hdfc_payment(payment_detail_params.as_json.with_indifferent_access, transaction_log)
      respond_to do |format|
        format.json {
          render json: {
              success: 'Redirect to hdfc gateway',
              redirect_path: redirect_v2_pg_sy_hdfc_payments_path(url_params)
          }
        }
        format.html { redirect_to redirect_v2_pg_sy_hdfc_payments_path(url_params) }
      end
    end

    def payfast_payment
      begin
        raise SyException, "Please input first name." unless payment_detail_params[:name_first].present?
        raise SyException, "Please input last name." unless payment_detail_params[:name_last].present?
        raise SyException, "Please input a valid email address, that will be used to notify payment transaction." unless payment_detail_params[:email_address].to_s.is_valid_email?
        find_gatway_and_transaction_log
        payment_detail_params[:return_url] = registration_status_v2_event_orders_path
        payment_detail_params[:cancel_url] = payfast_fail_url('order_id')
        payment_detail_params[:notify_url] = payfast_paid_url
        if Rails.env.development?
          payfast_base_url = "https://d32ca7b0.ngrok.io"
          payment_detail_params[:return_url] = "#{payfast_base_url}#{registration_status_v2_event_orders_path}"
          payment_detail_params[:cancel_url] = "#{payfast_base_url}#{payfast_fail_path('order_id')}"
          payment_detail_params[:notify_url] = "#{payfast_base_url}#{payfast_paid_path}"
        end
        url = @gateway.model.constantize.create_payfast_payment(payment_detail_params.as_json.with_indifferent_access, @transaction_log)
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue StandardError => e
        Rollbar.error(e)
        message = e.message
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
      end
      raise SyException, message if message.present?
      logger.info("Redirect url for event_order id: #{@event_order.id} \n #{url}")
      redirect_to url, notice: 'Processing your payment. Please do not close or refresh.'
    end

    def braintree_payment
      # Transaction Log
      gateway = TransferredEventOrder.gateways.find { |g| g[:symbol] == params[:method] }
      transaction_log = TransactionLog.create(transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], request_params: payment_detail_params)
      braintree_payment, message = PgSyBraintreePayment.create_braintree_payment(payment_detail_params.as_json.with_indifferent_access, transaction_log)
      raise message if message.present?
      braintree_payment.event_order.update_attributes(transaction_id: braintree_payment.braintree_payment_id, payment_method: 'Braintree Payment', status: braintree_payment.status)
      begin
        # Update event order line items and event registrations as payment completed.
        braintree_payment.event_order.perform_updation(payment_detail_params[:details].as_json.collect(&:with_indifferent_access))
      rescue => e
        Rollbar.error(e)
      end
      # Send joining email
      braintree_payment.event_order.notify_joining if braintree_payment.try(:event_order).try(:event).try(:notification_service)
      flash[:success] = 'Payment received successfully.'
      redirect_to @event_order.sy_club ? complete_v2_forum_path(@event_order) : complete_v2_event_order_path(@event_order)
    end

    def find_gatway_and_transaction_log
      @gateway = TransferredEventOrder.gateways.find { |g| g[:symbol] == params[:method] }
      @transaction_log = TransactionLog.create(transaction_loggable_id: payment_detail_params[:event_order_id], transaction_loggable_type: controller_name.classify.to_s, other_detail: @event_order.other_detail(payment_detail_params), transaction_type: TransactionLog.transaction_types[:pay], gateway_type: @gateway[:gateway_type], gateway_name: @gateway[:symbol], request_params: payment_detail_params.as_json.with_indifferent_access)
    end

    def get_reg_payment_summary_object(registration_payment_summary = {})
      registration_payment_summary = registration_payment_summary.with_indifferent_access
      res = {
          total_registration_fee: registration_payment_summary[:total_registration_fee] || registration_payment_summary[:original_amount] || 0.0,
          totol_discount: registration_payment_summary[:total_discount] || registration_payment_summary[:discount] || 0.0,
          tax_breakup: registration_payment_summary[:tax_breakup] || 0.0,
          total_tax_amount: (registration_payment_summary[:tax_breakup] || []).reduce(0.0) { |sum, obj| sum + obj["amount"] || 0.0 }
      }
      res[:total_payable_amount] = res[:total_registration_fee] - res[:totol_discount] + res[:total_tax_amount]
      res
    end

    public

    # complete /event_orders/1/complete
    def complete
      @event = @event_order.event
      raise "Registrations are not allowed for this event." unless is_event_running?(@event)
      raise "Please don't attempt payments twice for same SYIDs. If fees is deducted from account and registration number not received then please inform Ashram helpline number or email to #{GetSenderEmail.call(@event)} within 2 days of your transation." if @event_order.pending?

      @currency = @event.currency_code
      @gateway = TransferredEventOrder.gateways.find { |g| g[:payment_method] == @event_order.payment_method }

      if @gateway.present?
        @payment = @gateway[:model].try(:constantize).try(:where, { @gateway[:transaction_id] => @event_order.transaction_id }).try(:last)

        search_in_statuses = TransactionLog.statuses.slice(:success).values
        search_in_statuses << TransactionLog.statuses['pending'] if @event_order.payment_method == 'Demand draft'
        gateway_transaction_id = @payment.send("#{@gateway[:transaction_id]}")
        gateway_transaction_id = @payment.charge_id if @event_order.payment_method == 'Stripe Payment'

        if @gateway[:model].try(:constantize).statuses[@payment.status] == @gateway[:success]
          # Find transaction log
          transaction_log = @event_order.transaction_logs.where(gateway_transaction_id: gateway_transaction_id, status: search_in_statuses, transaction_type: TransactionLog.transaction_types[:pay], gateway_name: @gateway[:symbol]).last
          @event_order_line_items = EventOrderLineItem.where(id: transaction_log[:other_detail]['line_items'])
          @is_payment_successful = true
        else
          # Find transaction log
          transaction_log = @event_order.transaction_logs.where(gateway_transaction_id: gateway_transaction_id, transaction_type: TransactionLog.transaction_types[:pay], gateway_name: @gateway[:symbol]).last
          @event_order_line_items = EventOrderLineItem.where(id: transaction_log[:other_detail]['line_items'])
          @is_payment_successful = false
        end
      else
        @event_order_line_items = @event_order.event_order_line_items
      end
    rescue StandardError => e
      Rollbar.error(e)
      Rails.logger.info(e)

      flash[:alert] = e.message
      redirect_to registration_details_v2_event_order_path(@event_order)
    end

    def hdfc_complete
      @event = @event_order.event

      raise "Transaction not found." unless params[:transaction_log_id].present? && @transaction_log = @event_order.transaction_logs.where(id: params[:transaction_log_id]).try(:last)
      raise "Registrations are not allowed for this event." unless is_event_running?(@event)
      raise "Please don't attempt payments twice for same SYIDs. If fees is deducted from account and registration number not received then please inform Ashram helpline number or email to #{GetSenderEmail.call(@event)} within 2 days of your transation." if @event_order.pending?

      @currency = @event.currency_code

      raise "Gateway not found." unless @gateway = TransferredEventOrder.gateways.find { |g| g[:symbol] == @transaction_log.gateway_name }
      raise "Payment not found." unless @payment = @gateway[:model].try(:constantize).try(:where, { @gateway[:transaction_id] => @transaction_log.gateway_transaction_id }).try(:last)

      @is_payment_successful = @gateway[:model].try(:constantize).statuses[@payment.status] == @gateway[:success]
      @event_order_line_items = EventOrderLineItem.where(id: @transaction_log[:other_detail]['line_items'])
      @other_details = @transaction_log[:other_detail].try(:with_indifferent_access)
      @tax_details = (@other_details.try(:dig, :tax_details) || {}).try(:with_indifferent_access)
      @gateway_charges = (@other_details.try(:dig, :gateway_charges) || {}).try(:with_indifferent_access)
    rescue StandardError => e
      Rollbar.error(e)

      flash[:alert] = e.message
      redirect_to v2_event_path(@event)
    end

    #save new status of event order
    def update_status
      authorize @event_order
      begin
        update_event_order_status(params[:status])
        @event_order.update_columns(reg_ref_number: "manual_" + @event_order.reg_ref_number) if @event_order.success?

      rescue SyException, AASM::InvalidTransition => e
        @message = e.message
        if @event_order.errors.present?
          error = @event_order.errors.messages.first
          @message = error.is_a?(Array) ? error.flatten.join(' ') : error
        end
      end
      @message.present? ? flash[:error] = @message : flash[:success] = "Status Updated Successfully."
      respond_to do |format|
        format.js
        format.html { redirect_back(fallback_location: proc { root_path }) }
      end
    end

    def bulk_update_event_order_status
      event_order_ids = bulk_update_event_order_status_params[:event_order_ids].split(",").map(&:to_i)
      event_orders = EventOrder.where(id: event_order_ids)

      raise "Please select at least one event order." unless event_orders.present?

      authorize event_orders.last

      ActiveRecord::Base.transaction do
        event_orders.each do |event_order|
          @event_order = event_order
          update_event_order_status(bulk_update_event_order_status_params[:status])
        end
      end
      flash[:success] = "Information Updated Successfully."
      redirect_back fallback_location: root_path
    rescue StandardError => e
      Rollbar.error(e)
      flash[:alert] = e.message
      redirect_back fallback_location: root_path
    end

    def update_event_order_status(status)
      aasm_event = EventOrder.statuses.key(status.to_i).to_s
      raise 'Please select a valid status' unless aasm_event.present?
      @event_order.send(aasm_event.to_sym) && @event_order.save
    end

    def resend_pre_approval_email
      authorize @event_order

      @event = @event_order.event
      raise "Event: #{@event.event_name} is not configured as pre approval event." unless @event.pre_approval_required?
      raise 'No approver found to send email.' unless @event.approver_email.present?
      @event_order.pre_approval_application_details
      flash[:success] = "Soon you will get email on #{@event.approver_email.to_s.split(',').to_sentence}."
      redirect_back fallback_location: root_path
    rescue StandardError => e
      Rollbar.error(e)
      flash[:error] = e.message
      redirect_back fallback_location: root_path
    end

    def resend_transaction_receipt_email
      authorize @event_order

      ResendTransactionReceiptEmail.call @event_order
      flash[:success] = "Transaction receipt has been resend successfully to email(s): #{recipients}."
      redirect_to registration_details_v2_event_order_path(@event_order)
    rescue StandardError => e
      Rollbar.error(e)
      flash[:error] = e.message
      redirect_to registration_details_v2_event_order_path(@event_order)
    end

    def registration_receipt
      receipt = @event_order.generate_registration_receipt
      filename = "#{@event_order.event.try(:event_name)}_registration_receipt_#{params[:event_id]}.pdf"
      send_data receipt, filename: filename
    rescue StandardError => e
      Rollbar.error(e)
      render file: 'customs/422.html.erb', locals: {
        title: 'Event Entry Card Download Error.',
        message: e.message
      }
    end

    def pre_approval_complete
      @event = @event_order.event
      @event_order_line_items = @event_order.event_order_line_items
      @currency = @event.currency_code
      raise "Registrations are not allowed for this event." unless is_event_running?(@event)
      raise "You are not eligible to access this page." unless @event_order.pending?
    rescue StandardError => e
      Rollbar.error(e)
      flash[:alert] = e.message
      redirect_to v2_event_path(@event)
    end

    def payment_mode_details
      begin
        raise "No Associated Payment Gateway Found." unless @payment_gateway.present?
        raise "Amount not found." unless params[:amount].present?
        @currency = @event.currency_code
        @amount = params[:amount].rnd
        @upgrade = params[:upgrade].to_bool
        @parent_event_order_id = params[:parent_event_order_id]
      rescue StandardError => e
        Rollbar.error(e)
        @message = e.message
      end

      respond_to do |format|
        format.js
      end
    end

    def pre_approval_event_application
      begin
        message = nil
        begin
          decrypted_data = params[:token].decrypt
        rescue StandardError => e
          Rollbar.error(e)
          message = 'Invalid token.'
        end
        raise SyException, message if message.present?
        reg_ref_number, timestamp, action = decrypted_data.split(',')
        @event_order = EventOrder.find_by(reg_ref_number: reg_ref_number)
        raise SyException, 'Event application is not found. Please contact Ashram.' unless @event_order.present?
        raise SyException, 'Event end date cannot blank. Please contact Ashram' unless @event_order.event.event_end_date.present?
        raise SyException, 'Event is closed. Please contact Ashram.' if @event_order.event.event_end_date < Time.zone.now.to_date
        raise SyException, 'Action has been already taken for this application.' if EventOrder.statuses.pending != EventOrder.statuses[@event_order.status]
        if EventOrder.statuses['approve'] == EventOrder.statuses[action]
          @event_order.update(status: EventOrder.statuses[action])
          @message = "Application with reference number #{@event_order.reg_ref_number} has been approved successfully."
        elsif EventOrder.statuses['rejected'] == EventOrder.statuses[action]
          @event_order.update(status: EventOrder.statuses[action])
          @message = "Application with reference number #{@event_order.reg_ref_number} has been disapproved successfully."
        else
          @message = 'Please select a valid action (approve/reject).'
        end
        @from = GetSenderEmail.call(@event_order.event)
      rescue SyException => e
        @error_message = e.message
      rescue StandardError => e
        Rollbar.error(e)
        @error_message = e.message
      end
    end
  end
end
