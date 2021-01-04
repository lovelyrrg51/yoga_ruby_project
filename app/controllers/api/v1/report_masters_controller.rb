module Api::V1
  class ReportMastersController < BaseController
    before_action :authenticate_user!, except: [:generate_report]
    before_action :set_report_master, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:generate_report]
    respond_to :json
  
    # GET /report_masters
    def index
      @report_masters = ReportMaster.all
      render json: @report_masters
    end
  
    # GET /report_masters/1
    def show
      authorize @report_master
      render json: @report_master
    end
  
    # GET /report_masters/new
    def new
      @report_master = ReportMaster.new
    end
  
    # GET /report_masters/1/edit
    def edit
    end
  
    # POST /report_masters
    def create
      @report_master = ReportMaster.new(report_master_params)
      authorize @report_master
      if @report_master.save
        render json: @report_master
      else
        render json: @report_master.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /report_masters/1
    def update
      authorize @report_master
      if @report_master.update(report_master_params)
        render json: @report_master
      else
        render json: @report_master.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /report_masters/1
    def destroy
      authorize @report_master
      @report_master.destroy
      render @report_master
    end
  
    def generate_report
      begin
  
        report_master = ReportMaster.find_by_id(params[:report_master_id])
  
        raise SyException, 'Please select a valid report type.' unless report_master.present?
  
        can_generate_report = false
  
        report_master.required_params.each do |required_param|
          required_model = required_param.tr('_id', '')
          required_model = required_model.camelize.constantize rescue nil
          next unless required_model.present?
          required_model = required_model.find_by_id(params[required_param])
          can_generate_report ||= ReportMasterPolicy.new(current_user, required_model).generate_report?
          break if can_generate_report
        end
  
        raise SyException, 'You are not authrozied.' unless can_generate_report
  
        # Verify required params
        report_master.required_params.each do |rp|
          raise SyException, "#{rp.titleize} cannot be blank." unless params.has_key?(rp) or params[rp].present?
        end
  
        recipients = ((params[:email] || params[:recipients]).try(:split, ',').try(:extract_valid_emails).try(:uniq) || [])
        raise SyException, 'Please input valid email(s) to receive report.' unless recipients.present?
  
        t_config = {file_name: "#{report_master.report_name}_report", prefix: "#{ENV['ENVIRONMENT']}/reports/#{report_master.report_name}", template: 'search_sadhak_result', sync: false}
  
        task = Task.new(taskable_id: current_user.try(:id), taskable_type: 'User', email: recipients.join(','), opts: params, t_config: t_config, start_block: report_master.start_block, final_block: report_master.final_block)
  
        raise SyException, task.errors.full_messages.first unless task.save
  
        # Call task method that will produce result
        task.delay.create_subtasks
  
      rescue SyException => e
        is_error = true
        result = e.message
      rescue Exception => e
        is_error = true
        result = e.message
      end
      # Decision based on is error
      if is_error
        render json: {errors: {Error: ["#{report_master.report_name.try(:titleize)} download error (#{result})"]}}, status: :unprocessable_entity
      else
        render json: {success: {Succcess: ["#{report_master.report_name.try(:titleize)} request received. Soon you will get email on #{recipients.join(',')}"]}}
      end
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_report_master
      @report_master = ReportMaster.find(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def report_master_params
      params.require(:report_master).permit(:report_name)
    end
  end
end
