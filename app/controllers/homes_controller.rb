class HomesController < ApplicationController
  include HomesHelper

  before_action :set_home, only: [:show, :edit, :update, :destroy]

  # GET /homes
  def index
    statuses, clp_event_ids, current_date = [Event.statuses.ready,Event.statuses.test_registration], Event.clp_event_ids, Time.zone.now.strftime('%Y-%m-%d')
    upcoming_events =  Event.includes(:event_payment_gateway_associations).where('id NOT IN (?) AND status IN (?) AND event_start_date > ? AND event_end_date > ? ', clp_event_ids, statuses, Time.now.strftime('%Y-%m-%d'), Time.now.strftime('%Y-%m-%d'))
    ongoing_events =  Event.includes(:event_payment_gateway_associations).where('id NOT IN (?) AND status IN (?) AND event_start_date <= ? AND event_end_date >= ? ', clp_event_ids, statuses, Time.now.strftime('%Y-%m-%d'), Time.now.strftime('%Y-%m-%d'))
    
    @babaji_upcoming_events = upcoming_events.select { |event| event.graced_by == 'Baba ji' }

    @ishanji_upcoming_events = upcoming_events.select { |event| event.graced_by == 'Ishan ji' }

    @babaji_ongoing_events = ongoing_events.select { |event| event.graced_by == 'Baba ji' }

    @ishanji_ongoing_events = ongoing_events.select { |event| event.graced_by == 'Ishan ji' }

    @nearest_shivyog_forums = SyClub.includes(address:[:db_country, :db_state, :db_city]).filter({lat: lat, lng: lng}).limit(6)

    # Logged in sadhak registered events
    @sadhak_upcoming_event_registrations = []
    @sadhak_photo_approval_events = []

    if current_sadhak_profile.present?

      event_ids = GlobalPreference.where(key: %w(india_clp_events global_clp_events)).collect{|gp| gp.try(:val).to_s.split(',')}.flatten

      @sadhak_upcoming_events = current_sadhak_profile.events.where('events.event_start_date >= ? AND events.id NOT IN (?)', (Date.today - 1.day), event_ids).order('events.event_end_date').limit(3)

      @sadhak_upcoming_event_registrations = current_sadhak_profile.event_registrations.joins(:event).where('event_registrations.status IN (?) AND events.event_start_date >= ? AND events.id NOT IN (?)', EventRegistration.valid_registration_statuses, (Date.today - 1.day), event_ids).includes(:event, :event_order).order('events.event_end_date')

      # Select event for which photo approval
      # Need to be optimized

      @sadhak_photo_approval_events = current_user.role_dependencies.includes({user_role: [:role]}).where(roles: {name: 'photo_approval_user'}, role_dependencies: {role_dependable_type: 'Event'}).select{|role_dependency|
        !role_dependency.is_restriction || (role_dependency.start_date..role_dependency.end_date).include?(Date.today)}.collect{|role_dependency| role_dependency.role_dependable}

      # @sadhak_photo_approval_events = current_user.role_dependencies.joins({user_role: [:role]}).where('roles.name = ? AND role_dependencies.role_dependable_type = ? OR role_dependencies.is_restriction = ? OR role_dependencies.start_date <= ? AND role_dependencies.end_date >= ?', 'photo_approval_user', 'Event', false, Date.today, Date.today)

    end

    if signed_in? && current_user.super_admin?

      @total_monthly_revenue = 0
      @total_daily_revenue = 0

      TransferredEventOrder.gateways.each do |gateway|

        @total_monthly_revenue += Object.const_get(gateway[:model]).where("extract(month from created_at) = ? AND extract(year from created_at) = ?", Date.today.month, Date.today.year).sum("amount")
        @total_daily_revenue += Object.const_get(gateway[:model]).where("created_at = ?", Date.today).sum("amount")

      end

      @total_new_sadhak_registrations = SadhakProfile.where('DATE(created_at) IN (?)', Date.today.at_beginning_of_month..Date.today).count

      @total_event_started_in_current_month = Event.where('DATE(event_start_date) IN (:range) AND status = :status', {range: Date.today.at_beginning_of_month..Date.today.at_end_of_month, status: Event.statuses.ready}).count

      # Render Charts

      monthly_revenue_chart

      registered_sadhaks_by_gender_chart

      monthly_events_registration_chart

    end


  end

  def coming_soon
    render :layout => false
  end

  def terms_and_conditions
    @sy_event_company = SyEventCompany.find_by_name(TERMS_AND_CONDITION_COMPANY)
  end  

  def privacy_policy
    
  end  

  def refund_policy
  end

  def contact_us
    
  end  

  def about_shivyog
    
  end

  private
  
  def monthly_revenue_chart

      revenue_hash = {}
      TransferredEventOrder.gateways.each do |gateway|
        Object.const_get(gateway[:model]).where("extract(year from created_at) = ?",Date.today.year).group("DATE_TRUNC('month', created_at)").order("DATE_TRUNC('month', created_at) ASC").sum("amount").each{|k,v| revenue_hash[k.strftime("%b")] = revenue_hash[k.strftime("%b")].to_f.round(2) + v.to_f.round(2) }
      end
      data = Date::ABBR_MONTHNAMES.compact.collect{|mon| { label: mon.to_s, value: revenue_hash[mon].to_f.round(2) } }

      @monthly_revenue = data.present? ? Fusioncharts::Chart.new({
        type: "column2d",
        renderAt: "monthlyRevenueChartContainer",
        width: "100%",
        height: "300",
        dataFormat: "json",
        dataSource:  {
          chart: {
            caption: "Monthly Revenue " << Date.today.year.to_s,
            subCaption: "Shivyog",
            paletteColors: "#990000",
            xAxisName: "Month",
            yAxisName: "Revenues",
            theme: "fint"
          },
          data: data
        }
      }) : nil

  end

  def registered_sadhaks_by_gender_chart

    date_range = Date.today.at_beginning_of_month..Date.today.at_end_of_month
    data = SadhakProfile.where('DATE(created_at) IN (?)',date_range).group(:gender).count.collect{|k,v| {label: k.to_s, value: v.to_i} }

    @registered_sadhaks_by_gender = data.present? ? Fusioncharts::Chart.new({
        type: 'doughnut2d',
        renderAt: 'registeredSadhakByGenderChartContainer',
        width: '100%',
        height: '300',
        dataFormat: 'json',
        dataSource: {
            chart: {
                caption: "New Sadhak Profiles in " << Date.today.strftime("%B"),
                subCaption: "Per Month",
                numberPrefix: "",
                startingAngle: "20",
                showPercentValues: "1",
                showPercentInTooltip: "0",
                enableSmartLabels: "0",
                enableMultiSlicing: "0",
                decimals: "1",
                paletteColors:"f5707a,4bd396,3ac9d6",
                theme: "fint"
            },
            data: data
        }
    }) : nil

  end

  def monthly_events_registration_chart

    date_range = Date.today.at_beginning_of_month..Date.today.at_end_of_month
    data = EventRegistration.where(status: EventRegistration.valid_registration_statuses).joins(:event).where('events.event_start_date IN (?)', date_range).group('events.event_name').count.collect{|k,v| {label: k.to_s, value: v.to_i} }

    @monthly_events_registration = data.present? ? Fusioncharts::Chart.new({
        type: 'pareto2d',
        renderAt: 'ongoingEventRegistrationsChartContainer',
        width: '100%',
        height: '300',
        dataFormat: 'json',
        dataSource: {
            chart: {
                caption: "Sadhak Participated In " << Date.today.strftime("%B") << " Events",
                subCaption: "Events",
                paletteColors: "#990000",
                lineColor: "#262626",
                xAxisName: "Events List",
                pYAxisName: "No. of Sadhak",
                sYAxisname: "Cumulative Percentage",
                bgColor: "#ffffff",
                borderAlpha: "20",
                showCanvasBorder: "0",
                showHoverEffect: "1",
                usePlotGradientColor: "0",
                plotBorderAlpha: "10",
                showValues: "0",
                showXAxisLine: "1",
                xAxisLineColor: "#999999",
                divlineColor: "#999999",
                divLineIsDashed: "1",
                showAlternateHGridColor: "0",
                subcaptionFontBold: "0",
                subcaptionFontSize: "14"
            },
            data: data
        }
    }) : nil

    
  end

end
