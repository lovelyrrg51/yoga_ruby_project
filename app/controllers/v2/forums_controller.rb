module V2
  class ForumsController < BaseController
    before_action :encode_url, only: [:show, :transfer_complete]

    def index

      if params.dig(:q, :name_cont).blank? && request.format.json?
        begin
          latlng = [request.location.latitude, request.location.longitude]
          addresses = Address.forum.near(latlng, 1000).order('distance').limit(20).includes(:addressable)
          @forums = addresses.map(&:addressable)
        rescue
        end
      end

      @q = SyClub.ransack(params[:q])

      if @forums.blank?
        @forums = @q.result(distinct: true).page(params[:page]).per(20)
      end

      respond_to do |format|
        format.json do
          @forum_locations = to_map_data(@forums)
          render json: @forum_locations.to_json
        end
        format.js
        format.html
      end
    end

    def show
      @forum = @sy_club
    end

    def complete
      @event_order = EventOrder.find_by!(slug: params[:id])
      raise "No Forum is attached to the Event Order." unless @sy_club = @event_order.sy_club

      raise "No Event is attached." unless @event = @event_order.event

      raise "No valid CLP Event is attached to this Forum." unless @clp_event = @sy_club.clp_event

    rescue StandardError => e
      flash[:alert] = e.message
      Rollbar.error(e)
      Rails.logger.info(e)
      redirect_to register_v2_forum_path(@sy_club)
    end

    def transfer_complete
      begin

        redirect_to register_v2_forum_path(@sy_club) and return unless cookies[SY_CLUB_TRANSFER_DETAILS.encrypt.to_sym]

        sy_club_member_ids = JSON.parse(cookies[SY_CLUB_TRANSFER_DETAILS.encrypt.to_sym].decrypt)

        cookies.delete(SY_CLUB_TRANSFER_DETAILS.encrypt)

        @sy_club_member_action_details = SyClubMemberActionDetail.transfer.where(to_sy_club_member_id: sy_club_member_ids)

        @from_club = SyClubMember.unscoped.where(id: @sy_club_member_action_details.last.from_sy_club_member_id).last.try(:sy_club)
        @to_club = @sy_club_member_action_details.last.to_club

        @sy_club_members = SyClubMember.where(id: sy_club_member_ids)

      rescue Exception => e
        flash[:alert] = e.message
        redirect_to register_v2_forum_path(@sy_club)
      end
    end

    private

    def to_map_data(forums)
      map_list = []
      forums.each do |forum|
        hash = {}
        hash['id'] = forum&.id
        hash['name'] = forum&.name
        hash['lat'] = forum&.address&.latitude
        hash['lng'] = forum&.address&.longitude
        hash['time'] = ''
        hash['category'] = 'International Forum'
        hash['address'] = forum&.full_address
        hash['address2'] = ''
        hash['city'] = forum&.city_name
        hash['state'] = forum&.state_name
        hash['postal'] = forum&.address&.postal_code
        hash['phone'] = forum&.contact_details
        hash['web'] = ''
        hash['hours1'] = ''
        hash['hours2'] = ''
        hash['hours3'] = ''
        hash['featured'] = ''
        hash['features'] = ''
        hash['date'] = ''
        map_list.push(hash)
      end
      map_list
    end

    def set_sy_club
      @sy_club = SyClub.find(params[:id])
    end

    def encode_url
      if (params[:id].count("a-zA-Z") == 0)
        @sy_club = SyClub.find(params[:id])
        redirect_to url_for(params.permit!.except(:id).merge(id: @sy_club.slug)) if @sy_club.present?
      end
      set_sy_club
    end

  end
end
