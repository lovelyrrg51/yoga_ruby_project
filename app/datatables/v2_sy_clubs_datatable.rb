class V2SyClubsDatatable < ApplicationDatatable
    include Rails.application.routes.url_helpers

    private

    def data
      event_orders.map do |event_order|
        [].tap do |column|
          column << link_to(event_order.sy_club.name, v2_user_forum_subscription_path(event_order.sy_club), class: "red-text forum-subscription", remote: true)
          column << event_order.sy_club.id
          column << event_order.sy_club.address.country_name
          column << (event_order.sy_club.address.state_id == OTHER_STATE_ID ? "Other(#{event_order.sy_club.address.other_state})" : event_order.sy_club.address.state_name)
          column << event_order.sy_club.created_at.strftime("%d-%m-%Y")
        end
      end
    end

    def count
      event_orders.count
    end

    def total_entries
      event_orders.total_count
    end

    def event_orders
      @event_orders ||= current_user.event_orders.where(status: "success").where.not(sy_club_id: nil).page(page).per(per_page)
    end

    def search_columns
      %w(sy_clubs.id::text sy_clubs.name content_type contact_details email db_countries.name db_states.name db_cities.name addresses.other_state addresses.other_city)
    end

    def sort_columns
      %w(sy_clubs.name db_countries.name db_states.name,addresses.other_state db_cities.name,addresses.other_city sy_clubs.name)
    end

  end
