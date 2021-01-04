module Api::V1
  class TransactionLogsController < BaseController
    before_action :set_transaction_log, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: [:index, :create_metadata]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:index]
    respond_to :json
    # GET /transaction_logs
    def index
      @transaction_logs = TransactionLog.all
      render json: @transaction_logs
    end
  
    # GET /transaction_logs/1
    def show
      render json: @transaction_log
    end
  
    # GET /transaction_logs/new
    def new
      @transaction_log = TransactionLog.new
    end
  
    # GET /transaction_logs/1/edit
    def edit
    end
  
    # POST /transaction_logs
    def create(options = {})
      if options.present?
        @transaction_log = TransactionLog.create(transaction_loggable_id: options[:transaction_loggable_id], transaction_loggable_type: options[:transaction_loggable_type], other_detail: options[:other_detail])
      else
        @transaction_log = TransactionLog.new(transaction_log_params)
        if @transaction_log.save
          render json: @transaction_log
        else
          render json: @transaction_log.errors, status: :unprocessable_entity
        end
      end
    end
  
    # POST /transaction_logs/create_metadata
    def create_metadata
      begin
        event_order = EventOrder.includes(:event_order_line_items).find_by_id(create_metadata_params[:event_order_id])
        raise SyException, "Please place an event order first." if event_order.nil?
  
        sadhak_profile_ids = (create_metadata_params[:sadhak_profiles] || []).collect{|s| s[:syid]}.join(",")
        raise SyException, "Please provide sadhak profiles for logging." unless sadhak_profile_ids.present?
  
        transaction_log = TransactionLog.create
        metadata = {transaction_log_id: transaction_log.id, email: event_order.guest_email, event_order_id: event_order.id, event_id: event_order.event_id, sadhak_profile_ids: sadhak_profile_ids}
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue Exception => e
        message = e.message
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
      end
      if message.present?
        render json: {error: [message]}
      else
        render json: metadata
      end
    end
  
    # PATCH/PUT /transaction_logs/1
    def update
      if @transaction_log.update(transaction_log_params)
        render json: @transaction_log
      else
        render json: @transaction_log.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /transaction_logs/1
    def destroy
      tl = @transaction_log.destroy
      render json: tl
    end
  
    def locate_collection
      if params.has_key?("filter")
        @sy_clubs = TransactionLogPolicy::Scope.new(current_user, TransactionLog).resolve(filtering_params)
      else
        @sy_clubs = policy_scope(TransactionLog)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_transaction_log
        @transaction_log = TransactionLog.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def transaction_log_params
        params.require(:transaction_log).permit(:transaction_loggable_id, :transaction_loggable_type, :gateway_request_object, :gateway_response_object, :transaction_type, :gateway_transaction_id, :other_detail, :gateway_type, :gateway_name, :status)
      end
  
      # Create metadata params
      def create_metadata_params
        params.require(:transaction_log).permit!
      end
  
      def filtering_params
        params.slice(:transaction_log_id)
      end
  end
end
