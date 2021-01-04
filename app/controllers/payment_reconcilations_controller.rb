class PaymentReconcilationsController < ApplicationController
  
  before_action :authenticate_user!
  before_action :set_payment_reconcilation, only: [:generate_reconcilation_file]

  def index
    authorize(:payment_reconcilation, :index?)

    @payment_reconcilation = PaymentReconcilation.new
    @payment_reconcilation.attachments.build

    filtering_params.present? ? locate_collection : @payment_reconcilations = PaymentReconcilation.page(params[:page]).per(params[:per_page]).order(id: :desc)
  end
  
  def create

    PaymentReconcilationPolicy.new(current_user, nil).reconcilation?

    begin

      raise "File is missing. Please upload a file." unless @file = payment_reconcilation_params.dig(:attachments_attributes, "0", :content)

      PaymentReconcilation.proceed_for_reconcilation_upload({ method: "ccavenue", attachable_type: "PaymentReconcilation", bucket_name: ENV["ATTACHMENT_BUCKET"], current_user: current_user, attachable_id: nil, file: @file }.with_indifferent_access)
    rescue Exception => e
      message = e.message
    end
    message.present? ? flash[:alert] = message : flash[:success] = "Payment Reconcilation is successfully created."
    redirect_to payment_reconcilations_path

  end

  def generate_reconcilation_file

    authorize @payment_reconcilation

    begin  

      raise SyException.new("Invalid file type.") unless params[:file_type] && PaymentReconcilation::FILE_TYPE.values.map(&:to_s).include?(params[:file_type])

      raise SyException.new("Reconcilation process not completed due to some problems, try after some time when the file is ready to download") if params[:file_type].to_i != PaymentReconcilation::FILE_TYPE[:original] && !@payment_reconcilation.completed?

      file_url = @payment_reconcilation.get_url(PaymentReconcilation::FILE_TYPE.key(params[:file_type].to_i).to_s)

    rescue Exception => e
      message = e.message 
    end

    message.present? ? flash[:alert] = message : (send_file file_url, :filename => "#{params[:file_type]}_registration_list.xls")

  end

  def locate_collection
		@payment_reconcilations = PaymentReconcilationPolicy::Scope.new(current_user, PaymentReconcilation).resolve(filtering_params).page(params[:page]).per(params[:per_page]).order(id: :desc)
	end

  private

  def payment_reconcilation_params
    params.require(:payment_reconcilation).permit(:method, :reconcilation_ref_number, :file_name, :status, :user_id, :attachable_type, :message, :file_type, attachments_attributes: [ :id, :content ])
  end

  def filtering_params
    params.slice(:status, :upload_date, :file_name).select{ |k, v| v.present? }
  end

  def set_payment_reconcilation
    @payment_reconcilation = PaymentReconcilation.find(params[:id])
  end

end