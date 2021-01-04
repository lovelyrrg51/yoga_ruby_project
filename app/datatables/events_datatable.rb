class EventsDatatable < ApplicationDatatable
  delegate :shivir_details_event_path, to: :@view
  delegate :register_event_path, to: :@view
  delegate :image_tag, to: :@view
  delegate :has_asset?, to: :@view

  private

  def data

    b = binding
    events.map do |event|

      b.local_variable_set(:event, event)

      [].tap do |column|

        template = <<-EOF

          <div class="profile">
            <div class="profileimg">
              <%= image_tag has_asset?(event.graced_by.to_s.gsub(" ", "").downcase + "sm.png") ? event.graced_by.to_s.gsub(" ", "").downcase + "sm.png" : "profile.png", alt: "profile image"%>
            </div>
            <span><%= event.graced_by.try(:titleize) %></span>
          </div>

        EOF

        column << ERB.new(template, 0, "", "a").result(b)
        if params[:action_page].present? && (params[:action_page] == "upcoming_events")
          column << '<span class="primary-color">' + event.event_name + '</span>'
        else
          column << '<span class="primary-color">' + link_to(event.event_name, shivir_details_event_path(event), class: "primary-color text-center", target: "_blank") + '</span>'
        end
        column << event.id
        column << event.event_start_date.try(:strftime, '%d %b, %Y')
        column << event.event_end_date.try(:strftime, '%d %b, %Y')
        if params[:action_page].present? && (params[:action_page] == "upcoming_events")
          contacts = event.contact_details.split(',')
          column << contacts.map { |e| '<p>' + e.gsub(/\s+/, "") + (contacts.last == e ? '' : ',') + '</p>'}.join('')
          column << event.event_location
          column << link_to('REGISTER', register_event_path(event), class: "btn btn-info", target: "_blank")
        end
      end
    end
  end

  def count
    if params[:action_page] == 'upcoming_events'
      events.count
    else
      Event.count
    end
  end

  def total_entries
    events.total_count
  end

  def events
    @events ||= fetch_events
  end

  def fetch_events
    search_string = []
    search_columns.each do |term|
      search_string << "#{term} ILIKE :search"
    end
    events = Event.left_outer_joins({address: [:db_country, :db_state, :db_city]}).order("#{sort_column} #{sort_direction}")
    events = events.graced_by(params[:graced_by]) if params[:graced_by].present?
    if params[:action_page] == 'upcoming_events'
      events = events.where("event_start_date > ? AND event_end_date > ? AND status IN (?)", Time.now.strftime('%Y-%m-%d'), Time.now.strftime('%Y-%m-%d'),[Event.statuses.ready,Event.statuses.test_registration])
    end
    events = events.page(page).per(per_page)
    events = events.where(search_string.join(' OR '), search: "%#{params[:search][:value]}%")

    events = events.where(addresses: {country_id: params[:country_id]}) if params[:country_id].present?
    events = events.where(addresses: {state_id: params[:state_id]}) if params[:state_id].present?
    events = events.where(addresses: {city_id: params[:city_id]}) if params[:city_id].present?
    events = events.where("events.event_start_date >= ?", params[:event_start_date]) if params[:event_start_date].present?
    events = events.where("events.event_end_date <= ?", params[:event_end_date]) if params[:event_end_date].present?
    events = events.where("events.status = ?", params[:event_status]) if params[:event_status].present?
    events = events.where("events.event_type_id = ?", params[:event_type_id]) if params[:event_type_id].present?
    if params[:event_id_start_range].present? && params[:event_id_end_range].present?
      range = [params[:event_id_start_range].to_i, params[:event_id_end_range].to_i].minmax
      events = events.where("events.id IN  (?)", range[0]..range[1])
    elsif params[:event_id_start_range].present? || params[:event_id_end_range].present?
      range = [params[:event_id_start_range].to_i, params[:event_id_end_range].to_i].minmax
      events = events.where("events.id IN  (?)", range[0]..range[1])
    end
    events = events.where.not(addresses: { country_id: nil } )
    if current_user.try(:india_admin?) && !current_user.try(:super_admin?)
      events = events.where(addresses: {country_id: 113})
    end

    events
  end

  def search_columns
    %w(events.id::text event_name description graced_by contact_details additional_details event_location status_changes_notes registrations_recipients approver_email logistic_email prerequisite_message discount_text db_countries.name db_countries.id::text db_states.name db_states.id::text db_cities.name db_cities.id::text)
  end

  def sort_columns
    %w(graced_by event_name events.id event_start_date event_end_date event_name event_location contact_details)
  end
end
