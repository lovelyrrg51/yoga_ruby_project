class SyClubStepsController < ApplicationController

    include Wicked::Wizard
  
    before_action :set_sy_club, only: [:show, :update]
  
    steps :basic_info, :forum_details, :audio_visual_arrangements, :references

    def show

        begin

          authorize :sy_club, :update?

            case step

                when :basic_info
                  # club_sadhak_associations = @sy_club.sy_club_sadhak_profile_associations
                  #   if club_sadhak_associations >= 3
                  #     syclub_user_role = SyClubUserRole.all
                  #   elsif club_sadhak_associations == 2
                  #     syclub_user_role = SyClubUserRole.where(id: club_sadhak_associations.)
                  #   end 
                  #   SyClubUserRole.find_each do |role|
                  #     @sy_club.sy_club_sadhak_profile_associations.build(sy_club_user_role_id: role.id) unless @sy_club.sy_club_user_roles.include?(role)
                  #   end
                  #   binding.pry
                    @sy_club.sy_club_sadhak_profile_associations.includes(:sadhak_profile)

                  unless @sy_club.address.present?
                    address = @sy_club.build_address
                    address.build_db_country
                    address.build_db_state
                    address.build_db_city
                  end

                when :forum_details

                  @sy_club.build_sy_club_venue_detail if @sy_club.sy_club_venue_detail.blank?

                when :audio_visual_arrangements

                  @sy_club.build_sy_club_digital_arrangement_detail if @sy_club.sy_club_digital_arrangement_detail.blank?

                when :references

                  SyClub::NO_OF_SY_CLUB_REFERENCES.times { @sy_club.sy_club_references.build } if @sy_club.sy_club_references.blank?
            
            end

        rescue Exception => e
            flash[:alert] = e.message
            redirect_back(fallback_location: proc { members_sy_club_path(@sy_club) }) and return
        end

        render_wizard

    end

    def update

        begin

          authorize :sy_club, :update?
          @sy_club.content_type = params.dig(:sy_club, :content_type).try(:reject, &:empty?).try(:join, ",") if params.dig(:sy_club, :content_type).present?
          prev_board_members_ids = @sy_club.sy_club_sadhak_profile_associations.pluck(:sadhak_profile_id)
          @sy_club.update!(sy_club_params)

          @sy_club.send_updated_details if sy_club_params[:sy_club_sadhak_profile_associations_attributes].present? && prev_board_members_ids.present? && @sy_club.sy_club_sadhak_profile_associations.pluck(:sadhak_profile_id).any? { |id| prev_board_members_ids.exclude?(id) }
          
        rescue Exception => e
            flash[:alert] = e.message
            redirect_back(fallback_location: proc { members_sy_club_path(@sy_club) }) and return
        end

        render_wizard @sy_club.reload

    end

    def finish_wizard_path
      members_sy_club_path(@sy_club)
    end

    private

    def set_sy_club
        @sy_club = SyClub.find_by!(slug: params[:sy_club_id])
    end

    def sy_club_params
      params.require(:sy_club).permit(:name, :min_members_count, :content_type, :status_notes, :members_count, :status,  :email, :contact_details,
      sy_club_sadhak_profile_associations_attributes: [:id, :sadhak_profile_id, :club_joining_date, :status, :sy_club_id, :sy_club_user_role_id],
      address_attributes: [:id, :first_line, :second_line, :country_id , :state_id, :other_state, :city_id, :other_city, :postal_code],
      sy_club_venue_detail_attributes: [:id, :venue_type, :room_size, :windows_count, :fans_count, :doors_count, :room_color, :carpet_type, :yantras_count, :sy_club_id,:time, :room_other_activities, :painting_in_room, :lighting_arrangement],
      sy_club_digital_arrangement_detail_attributes: [:id, :dvd_player_model, :generator_company, :internet_data_plan, :internet_provider, :internet_speed, :inverter_company, :is_laptop_available, :lcd_model, :lcd_size, :speaker_model, :speakers_count],
      sy_club_references_attributes: [:id, :name])
    end
  
end