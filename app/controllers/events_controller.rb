class EventsController < ApplicationController
	include EventsHelper

	NON_STORABLE_ACTIONS = %w(datatables)

	before_action :set_event, only: [:show, :edit, :update, :destroy, :register, :photo_approval, :export_photo_approval_list, :photo_approval_admin, :registration_status, :application_status, :registration_change, :registration_invoices, :shivir_details, :tax_type, :registration_cancelation_policy, :new_category, :proposed_category, :registration_discount_plan, :cost_estimation_or_budget, :payment_gateway_options, :awareness, :additional_details, :transaction, :report, :event_status_update, :download_questionnaire_report]
	before_action :authenticate_user!, except: [:datatables,:register, :upcoming_events]
	before_action :render_404_if_clp_or_closed_event_for_non_admin, only:[:register]

	# GET /events
	def index

		authorize(:event, :index?)

		locate_collection

		if current_user.india_admin?

			@events = @events.filter({country_id: 113})

    end
    
    @replicate_events_list = Event.where.not("id IN (?)", Event.clp_event_ids)

	end

	def event_index

	end

	def datatables
		render json: EventsDatatable.new(view_context)
	end

	# GET /events/1
	def show
		authorize @event
	end

	# GET /events/autocomplet
	def autocomplete
		render json: Autocomplete::Events.new(view_context)
	end

	# GET /events/new
	def new
		@event = Event.new
		authorize @event
		address = @event.build_address
		address.build_db_country
		address.build_db_state
		address.build_db_city
		@event.attachments.build unless @event.attachments.present?
		@event.handy_attachments.build unless @event.handy_attachments.present?
	end

	# GET /events/1/edit
	def edit
	end

	# POST /events
	def create
		@event = Event.new(event_params)
		begin
			if @event.save
				flash[:success] = 'Event was successfully created.'
			else
				raise SyException, @event.errors.full_messages.first
			end
		rescue SyException => e
			message = e.message
		end

		if message.present?
		 	flash[:error] = message.to_s
			render :new
		else
			redirect_to shivir_details_event_path(@event), success: 'Event was successfully created.'
		end
	end

	# PATCH/PUT /events/1
	def update
		authorize @event
		begin
			if @event.update(event_params)
        flash[:success] = 'Event was successfully updated.'
			else
				raise SyException, @event.errors.full_messages.first
			end
		rescue SyException => e
      flash[:alert] = e.message
      Rollbar.error(e)
			Rails.logger.info(e.message)
    rescue ActiveRecord::RecordNotDestroyed => e
      flash[:alert] = e.record.errors.full_messages.first
      Rollbar.error(e)
			Rails.logger.info(e.record.errors.full_messages.first)
    rescue StandardError => e
      Rollbar.error(e)
			Rails.logger.info(e.inspect)
		end

		redirect_back(fallback_location: proc { root_path })
	end

	# DELETE /events/1
	def destroy
		@event.destroy
		redirect_to events_url, notice: 'Event was successfully destroyed.'
	end

  def locate_collection(_filtering_params = filtering_params)
		@events = EventPolicy::Scope.new(current_user, Event).resolve(_filtering_params).order('event_start_date DESC').page(params[:page]).per(params[:per_page]).includes(:event_type)
	end

	def register
    	@is_registrations_allowed = is_event_running?(@event)

		@event_order = EventOrder.new

	end

	def photo_approval

		authorize @event

		@photo_approval_panel_heading = "Photo Approval Panel : #{@event.event_name_with_location}"

		@sadhak_profiles = @event.vaild_registered_sadhak_profiles.filter(params.slice(:syid, :first_name, :email)).page(params[:page]).per(params[:per_page]).order(:id).includes({advance_profile: [:advance_profile_photograph, :advance_profile_identity_proof]})
	end


	def export_photo_approval_list
		begin

			authorize @event
			report_master = ReportMaster.find_by_id(params[:report_master_id])
			raise 'Please select a valid report type.' unless report_master.present?

			# Verify download list type
			raise "List type cannot be blank." unless params[:type].present?
			raise "Please provide a valid list type" unless %w(xls csv).include?(params[:type])

			# Verify required params
			report_master.required_params.each do |rp|
				raise "#{rp.titleize} cannot be blank." unless params.has_key?(rp) or params[rp].present?
			end

			recipients = (params[:recipients].try(:split, ',').try(:extract_valid_emails).try(:uniq) || [])
			raise "Please provide valid emails." if params[:recipients].present? && !recipients.present?

			sync = (not recipients.present?)

			if sync
				begin
					results = Timeout.timeout(5) do
						@event.vaild_registered_sadhak_profiles.order(:id)
					end
				rescue Timeout::Error
					raise 'We are not able to process your request for such large data. Please use email option.'
				end

				raise 'We are not able to process your request for such large data. Please use email option.' if results.size > 1000

				raise 'No sadhak profile(s) found, Try searching with some other criteria.' unless results.present?
			end

			t_config = {file_name: "#{report_master.report_name}_report", prefix: "#{ENV['ENVIRONMENT']}/reports/#{report_master.report_name}", template: 'search_sadhak_result', sync: sync}
			task = Task.new(taskable_id: current_user.try(:id), taskable_type: 'User', email: recipients.join(','), opts: params, t_config: t_config, start_block: report_master.start_block, final_block: report_master.final_block)

			raise task.errors.full_messages.first unless task.save

			if sync
				blob = task.create_subtasks
			else
				task.delay.create_subtasks
			end

		rescue Exception => e
			is_error = true
			message = e.message
		end

		unless is_error
			if recipients.present?
				# render file: 'customs/success.html.erb', :locals => {title: '', message: "Soon you will get an email on #{recipients.to_sentence}." }
				flash[:notice] = "Soon you will get an email on #{recipients.to_sentence}."
				redirect_back(fallback_location: proc { photo_approval_event_path(@event) })
			else
				send_data blob, :filename => "#{t_config[:file_name]}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.#{params[:type]}"
			end
		else
			flash[:alert] = message
			redirect_back(fallback_location: proc { photo_approval_event_path(@event) })
			# render file: 'customs/422.html.erb', :locals => {title: "#{report_master.report_name.try(:titleize)} Download Error.", message: message }
		end
	end

	# Photo approval role assignement page
	def photo_approval_admin
		authorize @event
		@role_dependency = RoleDependency.find_by_id(params[:role_dependency_id]) || RoleDependency.new
		@role_dependencies = RoleDependency.where(role_dependable_type: 'Event', role_dependable_id: @event.id).where.not(id: params[:role_dependency_id]).page(params[:page]).per(params[:per_page])
		@role = 'photo_approval_user'
	end

	def registration_status
    authorize @event
    @questionnaire_form_enabled = GlobalPreference.get_value_of('questionnaire_enabled_events')&.split(',')&.map(&:to_i)&.include?(@event.id)
    @event_registration_report = ReportMaster.find_by(report_name: "event_registration")
    @event_registration_tally_report = ReportMaster.find_by(report_name: "event_registration_tally")
    @event_registration_dd_cash_tally_report = ReportMaster.find_by(report_name: "event_registration_dd_cash_tally")
    @event_registrations = @event.event_registrations.filter(filtering_params).page(params[:page]).per(params[:per_page]).order('event_registrations.id').includes(:sadhak_profile, :event_order)
	end

	def registration_invoices
		authorize @event
		@event_registrations = @event.valid_event_registrations.filter(filtering_params).page(params[:page]).per(params[:per_page]).order('event_registrations.id').includes(:sadhak_profile, :event, :event_order, :attachments)
	end

	# Shivir details tabs

	def shivir_details
		authorize @event
		unless @event.address.present?
			address	= @event.build_address
			address.build_db_country
			address.build_db_state
			address.build_db_city
		end
		@event.attachment || @event.attachments.build
		@event.handy_attachment || @event.handy_attachments.build
	end

	def tax_type
		authorize @event
	end

	def registration_cancelation_policy
    authorize @event
    @event_cancellation_plan = @event.event_cancellation_plan
    @event_cancellation_plan_items = @event_cancellation_plan.try(:event_cancellation_plan_items)
	end

	def proposed_category
    authorize @event
    @event_registrations_on_seating_category = @event.valid_event_registrations.joins(:event_seating_category_association).group("event_seating_category_associations.id").count
	end

	def registration_discount_plan
		authorize @event
    @discount_plans =  DiscountPlan.all
    @discount_plan = @event.discount_plan
    @discount_plan_events = @discount_plan.try(:events)
	end

	def awareness
	end

	def additional_details
		authorize @event
	end

	def event_discount_plan_associations
		@discount_plan = DiscountPlan.find_by_id(params[:discount_plan_id])
		@discount_plan_events = @discount_plan.try(:events)
		respond_to  do |format|
			format.html  {}
			format.js  {}
		end
	end

	def edit_discount_plan

		begin
			@discount_plan = DiscountPlan.find_by_id(params[:discount_plan])
			raise SyException, "Select a discount plan." unless @discount_plan.present?
			@events = Event.where(id: params[:events])
			raise SyException, "No Event found associated discount_plan" unless @events.present?
	  	authorize @events.first
			ApplicationRecord.transaction  do
				@events.each do |event|
					@discount_plan.event_discount_plan_associations.create(event: event)
				end
			end
		rescue SyException => e
			message = e.message
		end

		if message.present?
			flash[:alert] = message
		else
			flash[:success] = "Successfully Discount plans are added to events"
		end
		redirect_back(fallback_location: proc { root_path })
	end

  def payment_gateway_options

    @event_payment_gateway_associations = {}

    @event.event_payment_gateway_associations.each do |pga|

      k = pga.payment_gateway.payment_gateway_type.name.upcase

      if @event_payment_gateway_associations[k].present?

        @event_payment_gateway_associations[k] << pga

      else

        @event_payment_gateway_associations[k] = [pga]

      end

    end

    @event.non_selected_payment_gateways.each do |payment_gateway|

      k = payment_gateway.payment_gateway_type.name.upcase

      if @event_payment_gateway_associations[k].present?

        @event_payment_gateway_associations[k] << @event.event_payment_gateway_associations.build(payment_gateway_id: payment_gateway.id)

      else

        @event_payment_gateway_associations[k] = [@event.event_payment_gateway_associations.build(payment_gateway_id: payment_gateway.id)]

      end

    end

  end

  #TODO
  def application_status
    authorize @event

    @event_orders = @event.event_orders.filter(filtering_params).page(params[:page]).per(params[:per_page]).order('event_orders.id DESC').includes(event: [:payment_gateway_types])

  end

  def transaction
     authorize @event

     @event_orders = @event.event_orders.filter(filtering_params).page(params[:page]).per(params[:per_page]).order("event_orders.id").includes({ user: :sadhak_profile }, :sadhak_profiles)

  end

	def show_event_transaction_details
		
		begin

			raise "No Event Order found." unless params[:event_order] && @event_order = EventOrder.find(params[:event_order])

		rescue Exception => e

			@message = e.message

		end
    
    respond_to  do |format|
      format.js
    end

	end
	
	def show_event_reg_change_details
		
		begin

			raise "No Event Order found." unless params[:event_order] && @event_order = EventOrder.find(params[:event_order])

			raise "No Payment Refund found." unless @payment_refund = PaymentRefund.find_by_id(params[:payment_refund_id]) if params[:payment_refund_id]

			@payment_refund.payment_refund_line_items.includes(:event_order_line_item, :sadhak_profile, :event_seating_category_association)

		rescue Exception => e

			@message = e.message

		end
    
    respond_to  do |format|
      format.js
    end

  end

  def show_event_transaction_receipt

    begin

      @event_order = EventOrder.find(params[:event_order]) if params[:event_order].present?
      raise "Event: show_event_transaction_receipt: Redirecting URL is not present." unless params[:redirect_url].present?
      @redirect_url = params[:redirect_url]
      respond_to  do |format|
        format.js
      end
      
    rescue Exception => e

      logger.info(e.message)
      redirect_back(fallback_location: proc { root_path })

    end

  end

  def show_resend_pre_approval_email

    begin

      @event_order = EventOrder.find(params[:event_order]) if params[:event_order].present?
      raise "Event: show_resend_pre_approval_email: Redirecting URL is not present." unless params[:redirect_url].present?
      @redirect_url = params[:redirect_url]
      respond_to  do |format|
        format.js
      end
      
    rescue Exception => e

      logger.info(e.message)
      redirect_back(fallback_location: proc { root_path })

    end

  end

  def show_payment_refund_amount_modal

    begin

      raise "Event: show_payment_reject_request_modal: No Max. refund amount found." unless params[:max_refund_amt].present?
      raise "Event: show_payment_reject_request_modal: No Redirecting URL found." unless params[:redirect_url].present?

      @max_refund_amt = params[:max_refund_amt]
      @redirect_url =  params[:redirect_url]
      respond_to  do |format|
        format.js
      end
      
    rescue Exception => e

      logger.info(e.message)
      redirect_back(fallback_location: proc { root_path })
      
    end

  end

  def show_payment_reject_request_modal

    begin

      raise "Event: show_payment_reject_request_modal: No Registration Reference Number found." unless params[:reg_ref_number].present?
      raise "Event: show_payment_reject_request_modal: No Redirecting URL found." unless params[:redirect_url].present?

      @reg_ref_number = params[:reg_ref_number]
      @redirect_url =  params[:redirect_url]
      respond_to  do |format|
        format.js
      end
      
    rescue Exception => e

      logger.info(e.message)
      redirect_back(fallback_location: proc { root_path })
      
    end

  end

  def registration_change
    authorize @event
    @payment_refunds = @event.payment_refunds.filter(filtering_params).page(params[:page]).per(params[:per_page]).includes({requester_user: [:sadhak_profile]}, {payment_refund_line_items: [:registered_sadhak_profile, :sadhak_profile]}, :event_order)
  end

  def report

    authorize @event

    @by_category_and_mode_of_payment_chart = chart_by_category_and_mode_of_payment

    @by_gender_chart = chart_by_gender

    @by_category_chart = chart_by_categories

    @by_mode_of_payments_chart = chart_by_mode_of_payments

    @by_profession_chart = chart_by_profession

    @by_country_chart = chart_by_country

    @by_age_group_chart = chart_by_age_group

    @by_previous_events_registered_chart = chart_by_previous_events_registered
    
  end

  def event_types
    @event_types = {}
		@event_types = EventType.try(CannonicalEvent.find(params[:event][:cannonical_event_id]).event_meta_type).pluck(:name, :id).to_h if params[:event][:cannonical_event_id].present?
	end

	# GET /events/upcomming_events
  def upcoming_events
	locate_collection(params_for_upcoming_events)
    @is_logged_in = current_user.present?
    @events = @events.where("events.id::text ILIKE :search OR event_name ILIKE :search", search: "%#{params[:search].strip}%") if @is_logged_in && params[:search].try(:strip).try(:length)
	@upcoming_events = @events.where("event_start_date >  ? AND event_end_date > ? AND status IN (?)", Time.now.strftime('%Y-%m-%d'), Time.now.strftime('%Y-%m-%d'), [Event.statuses.ready,Event.statuses.test_registration]).includes(address:[:db_city, :db_state, :db_country])
		# @events = @events.where(id: [712, 715, 780, 818] ).includes(address:[:db_city, :db_state, :db_country])
	end

  # GET /events/event_status_update
	def event_status_update

		authorize @event

		begin
      raise "Invalid status." unless Event.statuses[event_params[:status]].present?

      raise "You are not allowed to change status from #{@event.status.try(:titleize)} to #{event_params[:status].try(:titleize)}." unless @event.send("#{event_params[:status]}")

      raise "You are not authorized to cancel this event." if @event.cancelled? && !current_user.super_admin?

      @event.save!

      @event.delay.cancel_all_registrations(current_user.try(:id)) if @event.cancelled?

      @success = "Status has been successfully updated."
      
		rescue Exception => e
			@message = e.message
    end

    respond_to do |format|
      format.js {}
    end

  end
  
  def replicate

    begin

      raise "No Event found." unless @event = Event.find_by_id(event_replicate_params[:event_id])

      authorize @event

      raise "No. of Clones field must be greater than zero." if event_replicate_params[:replicas].to_i <= 0

      raise 'cannot create more than 50 replicas at once.' if event_replicate_params[:replicas].to_i > 50

      recipient = current_sadhak_profile.try(:email) || current_user.email

      raise 'No valid sadhak email found. Please update in profile section.' unless recipient.to_s.is_valid_email?

      @event.delay.replicate(event_replicate_params.slice(:replicas).merge({user_id: current_user.id, recipient: recipient}))

    rescue Exception => e
      message = e.message
    end

    message.present? ? flash[:alert] = message : flash[:success] = "Request submitted successfully. Soon you will get an email on #{recipient}"
    redirect_to events_path

  end

  def download_questionnaire_report
  	data = @event.questionnaire_report
  	send_data(data.file,
  :filename => "#{data.file_name} .xlsx",
  :type => "mime/type")
  end

  private

	# Use callbacks to share common setup or constraints between actions.
	def set_event
		if (params[:id].count("a-zA-Z") == 0)
			@event = Event.find(params[:id])
			redirect_to url_for(params.permit!.except(:id).merge(id: @event.slug)) if @event.present?
		end
		@event = Event.find(params[:id])
	end

	# Only allow a trusted parameter "white list" through.
	def event_params
    	params.require(:event).permit(:description, :pay_in_usd,:discount_plan_id, :event_cancellation_plan_id, :status, :event_type_id, :event_name,  :graced_by, :payment_category, :event_start_date, :event_end_date, :event_start_time, :event_end_time, :contact_details, :contact_email, :website, :description, :sy_event_company_id, :is_photo_proof_required, :video_url, :additional_details, :full_profile_needed, :venue_type_id, :sy_event_company, :cannonical_event_id, :show_seats_availability, :show_shivir_price, :end_date_ignored,:prerequisite_message, :notification_service, :has_seva_preference, :shivir_card_enabled, :registrations_recipients, :pre_approval_required, :auto_approve, :logistic_email, :approver_email, :min_age_criteria, :event_location, :automatic_refund, :next_financial_year, event_tax_type_associations_attributes: [:id, :percent, :event_id, :prerequisite_message, :notification_service, :tax_type_id, :_destroy], address_attributes:[:id, :first_line, :second_line, :city_id, :district, :state_id, :postal_code, :country_id, :address_type, :other_city, :other_state], :event_type_ids => [], :prerequisite_event_ids => [], event_seating_category_associations_attributes: [:id, :price, :seating_capacity, :event_id ,:seating_category_id,:_destroy], :attachments_attributes => [:content, :id, :remove_content], :handy_attachments_attributes => [:content, :id, :remove_content], event_payment_gateway_associations_attributes: [:id, :event_id, :payment_gateway_id, :payment_start_date, :payment_end_date, :_destroy])
	end

  def filtering_params
    params.slice(:event_type_id, :country_id, :sy_club_id, :entity_type, :status, :event_end_date, :graced_by, :state_id, :city_id, :syid, :first_name, :full_name, :reg_ref_number, :requester_name, :amount_refunded, :transaction_id, :invoice_number, :reg_invoice_from, :reg_invoice_to, :payment_method, :registered_by, :search_in_applied_sadhak_names)
  end

  def params_for_upcoming_events
    temp_params = {}  
    if current_user.present?
      temp_params = params.slice(:country_id, :graced_by, :state_id, :city_id)
    else
      temp_params = params.slice(:graced_by)
    end
    temp_params[:graced_by] = "" unless params[:graced_by].in?(%W(#{BABA_JI} #{SUBTLE_PRESENCE_OF_BABAJI}))
    temp_params
  end

  def chart_by_category_and_mode_of_payment
    
    by_category_and_mode_of_payment_data = @event.by_category_and_mode_of_payment

    Fusioncharts::Chart.new({
      width: "100%",
      height: "380",
      type: 'MSColumn2D',
      renderAt: "byCategoriesAndModeOfPaymentChartContainer",
      dataSource: {
        chart: {
          caption: "Registration By Categories & Mode of Payment",
          xAxisname: 'Seating Categories',
      	  yAxisName: 'Registration(s)',
          paletteColors: "#f7464a,#4bd396,#00bcd4",
          crossLineColor: "transparent",
          yAxisValuesStep: 1,
          theme: "fint"
        },
        categories: [{category: by_category_and_mode_of_payment_data.collect{|c| {label: c[:name]}}}
        ],
        dataset: by_category_and_mode_of_payment_data.collect{|o| o.except(:total, :name)}.first.keys.collect do |key|
          {
            seriesname: key,
            data: by_category_and_mode_of_payment_data.collect{|o| {value: o[key]} }
          }
        end
      }
    })

  end

  def pie_chart(caption, data, render_at)
    
    Fusioncharts::Chart.new({
      height: '300',
      width: '100%',
      type: 'doughnut2d',
      renderAt: render_at,
      dataSource: {
        chart: {
          caption: caption,
          startingAngle: '20',
          showLabels: '0',
          showLegend: '1',
          enableMultiSlicing: '0',
          slicingDistance: '0',
          showPercentValues: '1',
          showPercentInTooltip: '1',
          decimals: "0",
          useDataPlotColorForLabels: "1",
          plotTooltext: '$label: $datavalue',
          paletteColors: "#f7464a,#4bd396,#00bcd4",
          theme: 'fint'
        },
        data: data
      }
    })

  end

  def chart_by_gender

    pie_chart("Registration By Male-Female Ratio", @event.by_gender, 'byGenderChartContainer')
  
  end

  def chart_by_categories

    pie_chart("Registration By Categories", @event.by_category, 'bySeatingCategoriesChartContainer')

  end
  
  def chart_by_mode_of_payments

    pie_chart("Registration By Mode Of Payment(s)", @event.by_mode_of_payment, 'byModeOfPaymentChartContainer')

  end

  def column2d_chart(caption, data, render_at, x_axis_name = nil, y_axis_name = nil)
    
    Fusioncharts::Chart.new({
      height: '300',
      width: "100%",
      type: 'column2d',
      renderAt: render_at,
      dataSource: {
        chart: {
          caption: caption,
          paletteColors: "#990000",
          xAxisname: x_axis_name.to_s,
      	  yAxisName: y_axis_name.to_s,
          theme: 'fint'
        },
        data: data
      }
    })
  end

  def chart_by_profession
    
    column2d_chart('Registration(s) By Sadhak Profession', @event.by_profession, 'bySadhakProfessionChartContainer', 'Profession(s)', 'Registration(s)')

  end

  def chart_by_country
    
    column2d_chart('Registration(s) By Country', @event.by_country, 'bySadhakCountryChartContainer', 'Countries', 'Registration(s)')

  end

  def chart_by_age_group

    column2d_chart('Registration(s) By Age Group', @event.by_age_group, 'byAgeGroupChartContainer', 'Age (in Years)', 'Sadhak(s)')

  end

  def chart_by_previous_events_registered

    column2d_chart('Registration(s) By Previous Events Registered', @event.by_previous_events_registered, 'byPreviousEventsRegisteredChartContainer', 'Event(s)', 'Sadhak(s)')

  end

  def render_404_if_clp_or_closed_event_for_non_admin
  	raise ActiveRecord::RecordNotFound unless EventPolicy.new(current_user, :event).shivir_details? if @event.is_clp_event? || @event.closed?
  end

  def event_replicate_params
    params.require(:event).permit(:replicas, :event_id)
  end
  
end
