class SyClubsDatatable < ApplicationDatatable

    delegate :sy_club_path, to: :@view
  
    private
  
    def data

        sy_clubs.includes(address: [:db_country, :db_city, :db_state]).map do |sy_club|

            [].tap do |column|
    
                column << link_to(sy_club.name, sy_club_path(sy_club), target: "_blank", class: "primary-color text-center")
                column << sy_club.id
                column << sy_club.address.country_name
                column << (sy_club.address.state_id == OTHER_STATE_ID ? "Other(#{sy_club.address.other_state})" : sy_club.address.state_name)
                column << (sy_club.address.city_id == OTHER_CITY_ID ? "Other(#{sy_club.address.other_city})" : sy_club.address.city_name)
            end

        end

    end
  
    def count
      count = 0
      sy_clubs.collect{ |s| count+=1 } if sy_clubs.present?
      count
    end
  
    def total_entries
      sy_clubs.total_count
    end
  
    def sy_clubs
      @sy_clubs ||= fetch_sy_clubs
    end
  
    def fetch_sy_clubs

      search_string = []
      search_columns.each do |term|
        search_string << "#{term} ILIKE :search"
      end
      #sy_clubs = SyClub.left_outer_joins({address: [:db_country, :db_state, :db_city]}).order("#{sort_column} #{sort_direction}")
      sy_clubs = SyClub.left_outer_joins({address: [:db_country, :db_state, :db_city]}).order(ordering_params({ sort: sort_params }))
      sy_clubs = sy_clubs.page(page).per(per_page)
      sy_clubs = sy_clubs.where(search_string.join(' OR '), search: "%#{params[:search][:value]}%")
      sy_clubs = sy_clubs.where(addresses: {country_id: params[:country_id]}) if params[:country_id].present?
      sy_clubs = sy_clubs.where(addresses: {state_id: params[:state_id]}) if params[:state_id].present?
      sy_clubs = sy_clubs.where(addresses: {city_id: params[:city_id]}) if params[:city_id].present?
      if current_user.present?
        if SyClubPolicy.new(current_user, :sy_club).show?
          sy_clubs = sy_clubs.where.not(addresses: { country_id: nil } )
        elsif current_user.sadhak_profile.sy_clubs.present?
          sy_club_ids = sy_clubs.enabled.where.not(addresses: { country_id: nil } ).ids + current_user.sadhak_profile.sy_clubs.ids
          sy_clubs = sy_clubs.rewhere(id: sy_club_ids)
        else
          sy_clubs = sy_clubs.enabled.where.not(addresses: { country_id: nil } )
        end
      else
        sy_clubs = sy_clubs.enabled.where.not(addresses: { country_id: nil } )
      end
  
      sy_clubs
      
    end
  
    def search_columns
      %w(sy_clubs.id::text sy_clubs.name content_type contact_details email db_countries.name db_states.name db_cities.name addresses.other_state addresses.other_city)
    end

    def sort_columns
      %w(sy_clubs.name db_countries.name db_states.name,addresses.other_state db_cities.name,addresses.other_city sy_clubs.name)
    end

  end
  