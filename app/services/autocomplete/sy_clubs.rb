module Autocomplete
  class SyClubs < ApplicationAutocomplete
    delegate :register_sy_club_path, to: :@view

    private

    def result_partial(sy_club)
      ApplicationController.new.render_to_string(partial: 'sy_clubs/autocomplete', locals: { sy_club: sy_club, register_sy_club_path: register_sy_club_path(sy_club.slug) }).html_safe
    end

    def result_value(sy_club)
      sy_club.name
    end

    def results
      params[:term] = params[:term].to_s.strip
      @results ||= if params[:term].present? then
        SyClub.joins({address: [:db_country, :db_state, :db_city]}).where(make_query, query: "%#{params[:term]}%").limit(100).includes({address: [:db_country, :db_state, :db_city]}).order('db_cities.name')
      else
        SyClub.none
      end
    end

    def make_query
      %w(sy_clubs.name db_countries.name db_states.name db_cities.name addresses.postal_code addresses.first_line).map{|q| "#{q} ILIKE :query "}.join('OR ')
    end
  end
end
