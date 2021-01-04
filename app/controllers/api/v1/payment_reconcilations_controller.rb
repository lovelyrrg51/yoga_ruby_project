module Api::V1
  class PaymentReconcilationsController < BaseController
    before_action :authenticate_user! , :except => [:index, :show]
    before_action :set_payment_reconcilation, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:index, :show]
    respond_to :json
  
    # GET /payment_reconcilations
    def index
      @payment_reconcilations = policy_scope(PaymentReconcilation)
      render json: @payment_reconcilations.order('created_at DESC')
    end
  
    # GET /payment_reconcilations/1
    def show
    end
  
    # GET /payment_reconcilations/new
    def new
      @payment_reconcilation = PaymentReconcilation.new
    end
  
    # GET /payment_reconcilations/1/edit
    def edit
    end
  
    # POST /payment_reconcilations
    def create
      @payment_reconcilation = PaymentReconcilation.new(payment_reconcilation_params)
      authorize @payment_reconcilation
      if @payment_reconcilation.save
        render json: @payment_reconcilation
      else
        render json: @payment_reconcilation.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /payment_reconcilations/1
    def update
      authorize @payment_reconcilation
      if @payment_reconcilation.update(payment_reconcilation_params)
        render json: @payment_reconcilation
      else
        render json: @payment_reconcilation.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /payment_reconcilations/1
    def destroy
      authorize @payment_reconcilation
      @rec = @payment_reconcilation.destroy
      render json: @rec
    end
  
  # To upload data file and response to UI
    def reconcilation
      begin
        raise "You are not authorize to perform this action." unless PaymentReconcilationPolicy.new(current_user, nil).reconcilation?
        if params[:attachable_type].present? and params[:file].present?
          params[:method] ||= "ccavenue"
          params[:attachable_type] = "PaymentReconcilation"
          params[:bucket_name] = ENV["ATTACHMENT_BUCKET"]
          params[:current_user] = current_user
          params[:attachable_id] = nil
          result = PaymentReconcilation.proceed_for_reconcilation_upload(params)
        else
          is_error = true
          result = "Parameters missing."
        end
      rescue Aws::Errors::ServiceError => e
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
        render json: result
      else
        render json: {error: [e.message]}, status: :unprocessable_entity
      end
    end
  
  # To download reconcilation file, after all reconcilation process get completed
    def generate_reconcilation_file
      begin
        # raise exception in case of non-admin users.
        raise "You are not authorize to perform this action." unless PaymentReconcilationPolicy.new(current_user, nil).generate_reconcilation_file?
  
        raise SyException.new("Payment reconcilation id missing") unless params[:payment_reconcilation_id].present?
  
        raise SyException.new("File type not found") unless params[:file_type].present?
  
        raise SyException.new("Invalid file type") unless ['original', 'valid', 'invalid'].include?(params[:file_type])
  
        payment_reconcilation = PaymentReconcilation.find_by(id: params[:payment_reconcilation_id])
        raise SyException.new("No record found with this id") unless payment_reconcilation.present?
        raise SyException.new("Reconcilation process not completed due to some problems, try after some time when the file is ready to download") if !payment_reconcilation.completed? and params[:file_type] != 'original'
  
        file_url = payment_reconcilation.get_url(params[:file_type])
  
      rescue SyException => e
        is_error = true
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue Exception => e
        is_error = true
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        message = e.message
      end
  
      unless is_error
        send_file file_url, :filename => "#{params[:file_type]}_registration_list_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.xls"
      else
        render file: "invoices/custom_error.html.erb", :locals => {message: message}
        # render json: {error: [e.message]}, status: :unprocessable_entity
      end
  
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_payment_reconcilation
        @payment_reconcilation = PaymentReconcilation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def payment_reconcilation_params
        params.require(:payment_reconcilation).permit(:method, :reconcilation_ref_number, :file_name, :status, :user_id, :attachable_type, :message)
      end
  end
end
