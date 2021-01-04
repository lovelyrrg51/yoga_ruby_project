module Api::V1
  class PaymentRefundsController < BaseController
    before_action :authenticate_user!, except: []
    before_action :set_payment_refund, only: [:show, :edit, :update, :destroy, :refund]
    before_action :locate_collection, only: :index
    skip_before_action :verify_authenticity_token, only: []
    respond_to :json
  
    # GET /payment_refunds
    def index
      render json: @payment_refunds
    end
  
    # GET /payment_refunds/1
    def show
      render json: @payment_refund
    end
  
    # GET /payment_refunds/new
    def new
      render json: {}
    end
  
    # GET /payment_refunds/1/edit
    def edit
      render json: {}
    end
  
    # POST /payment_refunds
    def create
      @payment_refund = PaymentRefund.new(payment_refund_params)
      authorize @payment_refund
      if @payment_refund.save
        render json: @payment_refund
      else
        render json: @payment_refund.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # POST /payment_refunds/refund
    def refund
      authorize @payment_refund
      begin
        # Assign TransferredEventOrder model to variable
        @t = TransferredEventOrder
  
        # Raise error if status other than requested
        raise SyException, "We cannot process this request as its status is: #{@payment_refund.status}." unless ["requested"].include?(@payment_refund.status)
  
        @event = @payment_refund.try(:event)
        raise SyException, "Please select a valid event." unless @event.present?
  
        raise SyException, "Event is configured for automatic refund." if @event.automatic_refund?
  
        max_refundable_amount = @payment_refund.try(:max_refundable_amount).to_f.round(2)
        policy_refundable_amount = @payment_refund.try(:policy_refundable_amount).to_f.round(2)
        ui_amount = payment_refund_params[:amount].present? ? payment_refund_params[:amount].to_f.round(2) : policy_refundable_amount
  
        # Check UI amount, it should be lies in zero to max refundable amount
        raise SyException, "Amount (#{ui_amount}) you are trying to refund is invalid. Amount should be greater than or equal to 0 and less than or equal to #{max_refundable_amount}." if ui_amount < 0
  
        # Verify ui amount with max refundable amount
        raise SyException, "Amount you are trying to refund is invalid. Maximum refundable amount is : #{max_refundable_amount}" if ui_amount > max_refundable_amount
  
        # Check wether payment refund line items are attached or not
        raise SyException, "No payment refund requests are attached to ##{@payment_refund.id}." unless @payment_refund.payment_refund_line_items.present?
  
        request_object = ActiveSupport::HashWithIndifferentAccess.new(@payment_refund.request_object)
  
        # Extract parameters from payment_refund
        sadhak_profiles = request_object[:sadhak_profiles]
  
        @event_order = EventOrder.includes(:event).find_by_id(request_object[:event_order_id])
        raise SyException, "Event order not found." unless @event_order.present?
  
        # Perform some validations
        txn_details = @t.get_txn_details(request_object[:event_order_id])
        db_paid_amount = txn_details.collect{|t| t[:total_paid_amount]}.sum.to_f.round(2)
  
        # Raise error if any error while getting transaction details
        raise SyException, @t.get_refund_errors.first unless @t.get_refund_errors.empty?
  
        # Raise error if no amount left
        raise SyException, "Request amount cannot be refunded as #{db_paid_amount} amount left." if db_paid_amount < ui_amount
  
        # Create a fresh event order with success if transfer or transfer_downgrade case
        if [PaymentRefund.actions["transfer_downgrade"], PaymentRefund.actions["transfer"]].include?(PaymentRefund.actions[@payment_refund.action])
  
          # Wrap inside a single transaction
          ActiveRecord::Base.transaction do
  
            to_event = nil
            registrable_profiles = []
  
            # Check if applied sadhak is already registered to event
            @payment_refund.payment_refund_line_items.each do |item|
              to_event = item.event
              raise SyException, "SYID: #{item.try(:sadhak_profile).try(:syid)}, NAME: #{item.try(:sadhak_profile).try(:full_name)} is already registered to event #{item.try(:event).try(:event_name)}." if item.sadhak_profile.event_ids.include?(item.event_id)
  
              seats_occupied = to_event.event_registrations.where(event_seating_category_association_id: item.event_seating_category_association, :status => [nil, EventRegistration.statuses['updated']]).count
              total_seats = item.event_seating_category_association.seating_capacity
              seats_available = total_seats - seats_occupied
  
              registrable_profiles.push({sadhak_profile_id: item.sadhak_profile_id, event_seating_category_association_id: item.event_seating_category_association_id, is_extra_seat: (seats_available <= 0), price: item.event_seating_category_association.price, seating_category_id: item.event_seating_category_association.seating_category_id})
            end
  
            # Check wether event is registrable
            raise SyException, "Event is not ready for registrations." unless (@event.status == 'test_registration' or @event.status == 'ready' or (current_user.present? and (current_user.super_admin? or current_user.event_admin? or current_user.india_admin? or SadhakProfile.new.verify_by_rc(current_user, to_event.id))))
  
            # Create a fresh event order transfer details, Here we are creating event order with old guest email.
            @new_event_order = EventOrder.new(event_id: to_event.id, user_id: current_user.try(:id), guest_email: @event_order.guest_email.present? ? @event_order.guest_email : "syitemails@gmail.com")
  
            raise SyException, @new_event_order.errors.full_messages.first unless @new_event_order.save
  
            # Create line items
            registrable_profiles.each do |profile|
              line_item = @new_event_order.event_order_line_items.build(profile)
              raise SyException, line_item.errors.full_messages.first unless line_item.save
            end
  
          end
  
        end
  
        # Success parameters
        message = "We have successfully processed your request. #{@payment_refund.event.try(:notification_service) ? 'Soon you will get an email regarding your request.' : ''}"
        refunds = nil
        db_refunded_amount = 0.0
        partial_refund = nil
  
        # Increase data in refund object that is needed in transaction log
        request_object[:db_refundable_amount] = ui_amount
        request_object[:payment_refund_id] = @payment_refund.id
        request_object[:action] = @payment_refund.action
        request_object[:shifted_event_order_id] = @new_event_order.try(:id)
        request_object[:errors] = []
  
        if ui_amount > 0.0
          # Process refund
          refund_details = @t.process_refund(txn_details, ui_amount, request_object)
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
            request_object[:total_refunded_amount] = db_refunded_amount
            request_object[:refunds] = refunds
  
          elsif @t.get_refund_errors.count > 0
            raise SyException, @t.get_refund_errors.first
          else
            raise SyException, 'Something went wrong while processing your refund.'
          end
        end
  
        # Used to update event order line item discount.
        # downgraded = (@new_event_order.present? ? @new_event_order : @event_order).compute_info(sadhak_profiles: sadhak_profiles, reg_ref_number: request_object[:reg_ref_number], automatic_refund: true)
  
        # Temp
        @payment_refund.shifted_event_order_id = @new_event_order.try(:id)
  
        # Update @new_event_order if present
        if @new_event_order.present?
          # Update shifted/new event order to success with some transaction id assigned to it.
          request_object[:errors] += @new_event_order.errors.full_messages unless @new_event_order.update(status: 'success', transaction_id: "TRANSFER_FROM-#{@event_order.reg_ref_number}-#{SecureRandom.base64(8).to_s}")
  
          # Create a transferred event order entery in table and save it.
          transferred_event_order = @t.new(child_event_order_id: @new_event_order.id, parent_event_order_id: @event_order.id)
          request_object[:errors] += transferred_event_order.errors.full_messages unless transferred_event_order.save
        end
  
        # Update refunded amount and status and push errors to db if any while updation
        @payment_refund.update(amount_refunded: db_refunded_amount, status: @payment_refund.class.statuses["refunded"], shifted_event_order_id: @new_event_order.try(:id))
  
        # Update registrations and line items
        @payment_refund.perform_updation
  
        # Update request object with errors
        request_object[:errors] += @payment_refund.errors.full_messages
  
        # Clear all errors as request completed
        @payment_refund.errors.clear
  
        @payment_refund.update_columns(request_object: request_object.to_json)
  
        data = {refunds: refunds, total_refunded_amount: db_refunded_amount, event_order_id: request_object[:event_order_id], event_order_line_item_ids: sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]}, partial_refund: partial_refund, errors: @payment_refund.errors.full_messages}
  
        result = {success:{Status: [message], data: %w(development testing).include?(ENV['ENVIRONMENT']) ? data : {}}}
  
        # Fire email as payment refund success
        @payment_refund.reload.refund_email({refunds: refunds, total_refunded_amount: db_refunded_amount, partial_refund: partial_refund}) if @payment_refund.event.try(:notification_service)
  
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
        render json: {error: [result]}, status: :unprocessable_entity
      else
        render json: result
      end
    end
  
    # PATCH/PUT /payment_refunds/1
    def update
      authorize @payment_refund
      if @payment_refund.update(payment_refund_params)
        render json: @payment_refund
      else
        render json: @payment_refund.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /payment_refunds/1
    def destroy
      authorize @payment_refund
      if @payment_refund.update(is_deleted: true)
        render json: @payment_refund
      else
        render json: @payment_refund.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # GET /payment_refunds/registration_changes_report
    def registration_changes_report
      begin
        # Setup some default data
        params[:type] = params[:type].present? ? params[:type] : "other"
        params[:format] = params[:format].present? ? params[:format] : "excel"
        params[:format] = params[:format] == "excel" ? "xls" : params[:format]
  
        # Preload event
        event = Event.where(id: params[:event_id]).includes(:payment_refunds).last
  
        # Raise error if no event found
        raise SyException, "Please provide a valid event." unless event.present?
  
        # Validate is format type
        raise SyException, "Please provide a valid file format." unless ["csv", "xls"].include?(params[:format])
  
        # Is user authorized to perform oprtation
        raise SyException, "You need to sign in or sign up before continuing" unless EventPolicy.new(current_user, event).registration_changes_report?
  
        # Raise error if no manual requests found
        raise SyException, "Shivir #{event.try(:event_name)} does not have registration changes requests." if event.payment_refunds.size == 0
  
        # Raise error if not a valid report type found.
        raise SyException, "Please provide a valid report type." unless ["cancellation", "other"].include?(params[:type])
  
        # Get payment refund instance
        payment_refund = event.payment_refunds.last
  
        # If email present then create a background job
        if params[:email].present?
          payment_refund.delay.process_report_generate(params.slice(:event_id, :email, :format, :download, :type).merge(send_email: true))
        end
  
        # Generate a downloadable report
        blob = payment_refund.process_report_generate(params.slice(:event_id, :email, :format, :type).merge(download: true))
  
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
        render file: "customs/422.html.erb", :locals => { title: "Registration Changes Report Download Error.", message: result }
      else
        send_data blob, :filename => "#{event.event_name}_registrations_changes_report_#{params[:type]}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.#{params[:format]}"
      end
    end
  
    # Locate collection
    def locate_collection
      if params.has_key?("filter")
        @payment_refunds = PaymentRefundPolicy::Scope.new(current_user, PaymentRefund.preloaded_data).resolve(filtering_params)
      else
        @payment_refunds = policy_scope(PaymentRefund.preloaded_data)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_payment_refund
        @payment_refund = PaymentRefund.preloaded_data.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def payment_refund_params
        params.require(:payment_refund).permit(:status, :amount)
      end
  
      def request_params
        params.require(:payment_refund).permit!
      end
  
      def filtering_params
        params.slice(:requester_id, :responder_id, :event_id, :status, :event_order_id, :max_refundable_amount, :event_cancellation_plan_id)
      end
  
  end
end
