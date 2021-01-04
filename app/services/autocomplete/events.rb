module Autocomplete
  class Events < ApplicationAutocomplete
    delegate :photo_approval_admin_event_path, to: :@view

    private

    def result_partial(event)
      ApplicationController.new.render_to_string(partial: 'events/autocomplete', locals: { event: event, photo_approval_admin_event_path: photo_approval_admin_event_path(event) }).html_safe
    end

    def result_value(event)
      event.event_name
    end

    def results
      @results ||= Event.joins({address: [:db_country, :db_state, :db_city]}).where(make_query, query: "%#{params[:term]}%")
    end

    def make_query
      %w(event_name description graced_by contact_details additional_details event_location status_changes_notes registrations_recipients approver_email logistic_email prerequisite_message discount_text db_countries.name db_states.name db_cities.name).map{|q| "#{q} ILIKE :query "}.join('OR ')
    end
  end
end
