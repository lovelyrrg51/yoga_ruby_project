class ReportMastersController < ApplicationController
  include ReportMastersHelper

  before_action :authenticate_user!
  before_action :set_report_master, only: [:show, :edit, :update, :destroy, :generate_report, :process_report]

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

  def process_report

    begin

      # Find event
      event = Event.find_by_id(report_master_params[:event_id])
      raise SyException, 'Please select a valid event.' unless event.present?
      raise SyException, "Shivir: #{event.try(:event_name)} does not have any registrations." if event.event_registrations.count == 0

      event_registration = event.event_registrations.last    

      recipients = report_master_params[:email].try(:split, ',').try(:extract_valid_emails).try(:uniq)

      report_master_field_association_ids = report_master_params.dig(:report_master_field_association_ids)

      if report_master_field_association_ids.present?
        
        redirect_to generate_report_report_master_path(@report_master, { report_master: report_master_params.merge({report_master_field_association_ids: report_master_field_association_ids.join(",")}) }) and return

      else

        # Authorize operation
        raise 'You are not authorize to perform this action.' unless EventRegistrationPolicy.new(current_user, event_registration).generate_csv?

        event_registration.delay.process_report_generate(report_master_params.slice(:event_id, :download, :from, :to).merge({ send_email: true, recipients: recipients, user_id: current_user.try(:id), format: "xls" }))

      end

    rescue Exception => e
      is_error = true
      result = e.message
    end

    if is_error
      flash[:error] = result
    else
      flash[:success] = "Soon you will get email on #{recipients.join(',')}"
    end

    redirect_back(fallback_location: proc { root_path })    

  end

  def generate_report
    
    authorize @report_master

    begin

      report_master_params[:report_master_field_association_ids] = report_master_params[:report_master_field_association_ids].split(",") if report_master_params.has_key?(:report_master_field_association_ids) && report_master_params[:report_master_field_association_ids].is_a?(String)

      # Verify required report_master_params
      @report_master.required_params.each do |rp|
        raise "#{rp.titleize} cannot be blank." unless report_master_params.has_key?(rp) or report_master_params[rp].present?
      end

      recipients = ((report_master_params[:email] || report_master_params[:recipients]).try(:split, ',').try(:extract_valid_emails).try(:uniq) || [])
      raise "Please input valid email(s) to receive #{@report_master.report_name.titleize} report." unless recipients.present?

      t_config = {file_name: "#{@report_master.report_name}_report", prefix: "#{ENV['ENVIRONMENT']}/reports/#{@report_master.report_name}", template: 'search_sadhak_result', sync: false}

      task = Task.new(taskable_id: current_user.try(:id), taskable_type: 'User', email: recipients.join(','), opts: report_master_params, t_config: t_config, start_block: @report_master.start_block, final_block: @report_master.final_block)

      raise task.errors.full_messages.first unless task.save

      # Call task method that will produce result
      task.delay.create_subtasks

    rescue Exception => e
      is_error = true
      result = e.message
    end

    if is_error
      flash[:error] = result
    else
      flash[:success] = "#{@report_master.report_name.try(:titleize)} request received. Soon you will get email on #{recipients.join(',')}"
    end

    redirect_back(fallback_location: proc { root_path })
  
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_report_master
    @report_master = ReportMaster.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def report_master_params
    params.require(:report_master).permit!
  end

end
