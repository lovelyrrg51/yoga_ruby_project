module V2
  class ForumWizardController < BaseController
    include PaymentGatewayFormsHelper

    before_action :set_sy_club, only: [:register, :search_sadhak_profile, :verify_members, :process_club_members]

    def register
      begin

        raise "No valid CLP Event is attached to this Forum." unless @clp_event = @sy_club.clp_event

        @seat_data = @clp_event.event_seating_category_associations.includes(:seating_category).map do |seat|
          {
              id: seat.id,
              price: seat.price.to_f,
              category_name: seat.category_name,
              seats_available: seat.seats_available
          }
        end

        render template: 'v2/forums/register'
      rescue Exception => e
        # flash[:alert] = e.message
        p e.message
        redirect_back(fallback_location: proc { v2_forum_path })
      end
    end

    def verify_members
      begin

        raise "No valid CLP Event is attached to this Forum." unless @clp_event = @sy_club.clp_event

        @details = @sy_club.check_transfer(forum_transfer_params.merge(event_id: @clp_event.id, sadhak_profiles: forum_transfer_params[:event_order_line_items_attributes].values).as_json.with_indifferent_access)

        @sadhak_profiles = SadhakProfile.where(id: forum_transfer_params[:event_order_line_items_attributes].values.pluck(:syid))

        @encrypted_params = forum_transfer_params.to_json.encrypt

      rescue Exception => e
        @message = e.message
      end

      if @message.present?
        render json: { error: @message }
      else
        render json: { transfer: @details[:can_transfer],
                       renew: @details[:can_renew],
                       fresh: @details[:fresh_registration],
                       enc_params: @encrypted_params,
                       enc_key: SY_CLUB_DETAILS.encrypt,
                       data: @details[:data]
        }
      end
    end

    def process_club_members
      begin

        is_renewal_process = forum_transfer_params[:is_renewal_process].to_bool
        decrypted_forum_transfer_params = JSON.parse(forum_transfer_params[SY_CLUB_DETAILS.encrypt.to_sym]).with_indifferent_access

        raise "No valid CLP Event is attached to this Forum." unless @clp_event = @sy_club.clp_event

        @details = @sy_club.check_transfer(decrypted_forum_transfer_params.merge(event_id: @clp_event.id, sadhak_profiles: decrypted_forum_transfer_params[:event_order_line_items_attributes].values))

        raise "Some profile(s) are eligible for transfer/renew and some are new registration(s). cannot process together. Aborting." unless @details[:can_transfer] || @details[:can_renew] || @details[:fresh_registration]

        if @details[:fresh_registration] || (@details[:can_renew] && !@details[:can_transfer]) || (@details[:can_transfer] && @details[:can_renew] && is_renewal_process)

          is_renewal_process = true if (@details[:can_renew] && !@details[:can_transfer])

          #create event order
          @event_order = @clp_event.create_event_order(decrypted_forum_transfer_params.merge(current_user: current_user, event_id: @clp_event.id, sadhak_profiles: decrypted_forum_transfer_params[:event_order_line_items_attributes].values.each { |sp| sp[:sadhak_profile_id] = sp[:syid] }, sy_club_id: @sy_club.id, is_renewal_process: is_renewal_process))
          raise "New Event Order is not created." unless @event_order

          # redirect_to payment_sy_club_path(@event_order)

          raise "No Event is attached." unless @event = @event_order.event
          render json: { success: true, message: 'Event order was successfully created.' }.merge(ui_payment_data(@event_order, @event))
        elsif @details[:can_transfer]
          @sy_club.do_transfer(@details)
          cookies[SY_CLUB_TRANSFER_DETAILS.encrypt.to_sym] = { value: SyClubMember.joins(:event_registration).where(event_registrations: { id: @details[:data].try(:pluck, :event_registration_id) }).ids.to_json.encrypt, expiry: Time.now + (Rails.env.development? ? 60.minutes : 5.minutes) }
          render json: { success: true, redirect_path: transfer_complete_v2_forum_path(@sy_club), transfer: true }
        end

      rescue StandardError => e
        # flash[:alert] = e.message
        # redirect_to register_v2_forums_path(@sy_club)
        Rollbar.error(e)
        Rails.logger.info(e)
        render json: { error: e.message }, status: :unprocessable_entity
      end

    end

    private

    def set_sy_club
      @sy_club = SyClub.find(params[:id])
    end

    def forum_transfer_params
      params.require(:event_order).permit!
    end
  end
end