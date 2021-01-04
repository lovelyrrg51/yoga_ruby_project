class V2EventsDatatable < ApplicationDatatable
  include Rails.application.routes.url_helpers

  private

  def data
    events.map do |event|
      [].tap do |column|
        column << link_to(event.event_name, v2_user_registered_event_path(event.id), class: "red-text", remote: true)
        column << event.country_name
        column << event.state_name
        column << event.created_at.try(:strftime, '%d %b, %Y')
      end
    end
  end

  def count
    events.count
  end

  def total_entries
    events.total_count
  end

  def events
    search_string = []
    search_columns.each do |term|
      search_string << "#{term} ILIKE :search"
    end
    @events ||=
      current_user.sadhak_profile
        .events.includes(address: [:db_country, :db_state]).order("#{sort_column} #{sort_direction}")
        .page(page).per(per_page)
    @events = @events.where(search_string.join(' OR '), search: "%#{params[:search][:value]}%")
  end

  def search_columns
    %w(event_name)
  end

  def sort_columns
    %w(event_name db_countries.name db_states.name events.created_at)
  end
end
