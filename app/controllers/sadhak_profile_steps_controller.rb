class SadhakProfileStepsController < ApplicationController

  include Wicked::Wizard

  before_action :set_sadhak_profile, only: [:show, :update, :create_other_spiritual_association, :create_sadhak_profile_attended_shivir, :finish_wizard_path, :finish_page, :special_other_infos]

  before_action :set_event, only: [:show, :finish_wizard_path, :finish_page, :special_other_infos, :update]

  steps :basic_info, :advance_profile, :professional_detail, :doctors_profile, :self_reported, :name_of_guru, :other_spiritual_associations, :aspects_of_life, :sadhak_seva_preference, :medical_practitioners_profile, :special_other_infos
  # Commented as per discussion
  # steps :basic_info, :advance_profile, :professional_detail, :doctors_profile, :spiritual_practice, :spiritual_journey, :self_reported, :name_of_guru, :other_spiritual_associations, :aspects_of_life, :sadhak_seva_preference, :medical_practitioners_profile, :special_other_infos

  def show

    begin

      raise "No Sadhak Profile found" if @sadhak_profile.blank?

      case step

        when :basic_info

          if @sadhak_profile.is_basic_profile_complete? && @sadhak_profile.is_basic_profile_address_complete?
            unless @event.full_profile_needed?
              redirect_to finish_page_event_sadhak_profile_sadhak_profile_steps_path(@event, @sadhak_profile) and return
            else
              skip_step
            end
          else
            unless @sadhak_profile.address.present?
              address = @sadhak_profile.build_address
              address.build_db_country
              address.build_db_state
              address.build_db_city
            end
          end
          
        when :professional_detail

          if @sadhak_profile.is_professional_detail_complete?
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          else
            @professional_detail = @sadhak_profile.professional_detail || @sadhak_profile.build_professional_detail
          end

        when :doctors_profile

          if @sadhak_profile.is_not_doctor_profession? || (!@sadhak_profile.is_not_doctor_profession? && @sadhak_profile.is_doctors_profile_completed?)
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          else
            @country = DbCountry.pluck(:name, :id)
            @doctors_profile = @sadhak_profile.doctors_profile || @sadhak_profile.build_doctors_profile
          end

        when :advance_profile

          if @sadhak_profile.advance_profile.try(:is_complete?)
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          else

            @advance_profile = @sadhak_profile.advance_profile || @sadhak_profile.build_advance_profile
            @advance_profile.build_advance_profile_photograph unless @advance_profile.advance_profile_photograph.present?
            @advance_profile.build_advance_profile_identity_proof unless @advance_profile.advance_profile_identity_proof.present?
            @advance_profile.build_advance_profile_address_proof unless @advance_profile.advance_profile_address_proof.present?

          end

        when :spiritual_practice
          if @sadhak_profile.spiritual_practice.present?
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          else
            @spiritual_practice = @sadhak_profile.spiritual_practice || @sadhak_profile.build_spiritual_practice
          end

        when :spiritual_journey
          if @sadhak_profile.spiritual_journey.try(:is_complete?) 
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          else
            @spiritual_journey = @sadhak_profile.spiritual_journey || @sadhak_profile.build_spiritual_journey
          end

        when :self_reported

          if @sadhak_profile.sadhak_profile_attended_shivirs.present?
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          else
            @sadhak_profile_attended_shivir = @sadhak_profile.sadhak_profile_attended_shivirs.build
          end

        when :name_of_guru

          if @sadhak_profile.is_name_of_guru_complete?
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          end

        when :other_spiritual_associations

          if @sadhak_profile.other_spiritual_associations.present?
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          else
            @other_spiritual_association = @sadhak_profile.other_spiritual_associations.build
          end

        when :aspects_of_life

          if @sadhak_profile.aspects_of_life.blank?

            @sadhak_profile.create_aspects_of_life! 
            @aspect_feedback = @sadhak_profile.aspects_of_life.aspect_feedbacks

          else
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          end

        when :sadhak_seva_preference

          if @sadhak_profile.sadhak_seva_preference.try(:is_complete?)
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          else
            @sadhak_seva_preference = @sadhak_profile.sadhak_seva_preference || @sadhak_profile.build_sadhak_seva_preference
          end

        when :medical_practitioners_profile

          if @sadhak_profile.is_not_doctor_profession? || (!@sadhak_profile.is_not_doctor_profession? && @sadhak_profile.medical_practitioners_profile.try(:is_complete?))
            if params[:previous] && params[:previous].to_bool.is_a?(TrueClass)
              jump_to(previous_step, previous: true)
            else
              skip_step
            end
          else
            @medical_practitioners_profile = @sadhak_profile.medical_practitioners_profile || @sadhak_profile.build_medical_practitioners_profile
          end

        when :special_other_infos

          if @event.is_ashram_residential_shivir?
            if EventOrderLineItem.joins(event: [:event_type]).where('event_order_line_items.sadhak_profile_id = ? AND event_order_line_items.created_at > ? AND event_order_line_items.created_at <= ? AND event_types.name = ?', @sadhak_profile.id, (Time.zone.now - 6.months).beginning_of_day, Time.zone.now, ASHRAM_RESIDENTIAL_SHIVIR).exists? && SpecialEventSadhakProfileOtherInfo.exists?(sadhak_profile_id: @sadhak_profile.try(:id), event_id: @event.try(:id), event_order_line_item_id: nil)
              skip_step
            else
              @special_event_sadhak_profile_other_info = @sadhak_profile.special_event_sadhak_profile_other_infos.build
              2.times { @special_event_sadhak_profile_other_info.special_event_sadhak_profile_references.build }
            end
          else
            skip_step
          end

      end
      
    rescue Exception => e

      flash[:alert] = e.message
      redirect_back(fallback_location: proc { root_path }) and return
      
    end

    render_wizard

  end
  
  def update

    begin

      raise "No Sadhak Profile found" if @sadhak_profile.blank?

      case step

        when :basic_info

          update_model(@sadhak_profile.try(:address) || @sadhak_profile.build_address, sadhak_profile_params[:address_attributes])

          unless @sadhak_profile.is_verified?

            update_model(@sadhak_profile, sadhak_profile_params.except(:address_attributes, :email, :mobile))

            medium, sadhak_profile_verification_needed =  @sadhak_profile.update_or_verify(sadhak_profile_params.slice(:email, :mobile))

            # Delete cookies if any exist before store sadhak profile
            cookies.delete(NEW_SADHAK_PROFILE_COOKIE_KEY.encrypt)
            cookies.delete(EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt)

            # Store sadhak profile id in cookies.
            cookies.encrypted[EDIT_SADHAK_PROFILE_ID_COOKIE_KEY.encrypt] = @sadhak_profile.id
            cookies[RESEND_TIMER_KEY] = { value: RESEND_TIMER, expires: 30.seconds.from_now }
            cookies.encrypted[REDIRECT_URL_COOKIE_KEY.encrypt] = request.referrer

            # If email or mobile also will be update.
            flash[:success] = "Verification code has been successfully sent to your #{medium}."
            redirect_to sadhak_profile_token_verification_sadhak_profiles_path(edit_sadhak_profile: true) and return

          else

            update_model(@sadhak_profile, sadhak_profile_params.except(:address_attributes))

            redirect_to finish_page_event_sadhak_profile_sadhak_profile_steps_path(@event, @sadhak_profile) and return unless @event.full_profile_needed?

          end

        when :name_of_guru

          update_model(@sadhak_profile, sadhak_profile_params)

        when :aspects_of_life

          aspect_feedback_params.each do |id, update_attr|

            update_attr.keys.each{ |key|  update_attr[key] = update_attr[key].to_i }

            af = AspectFeedback.find_by_id(id.to_i)

            af.update!(update_attr)

          end

        when :advance_profile

          @sadhak_profile = update_model(@sadhak_profile.try(:advance_profile) || @sadhak_profile.build_advance_profile, sadhak_profile_params[:advance_profile_attributes].except(:advance_profile_photograph_attributes, :advance_profile_identity_proof_attributes, :advance_profile_address_proof_attributes))

          @sadhak_profile.advance_profile.try(:advance_profile_photograph) || @sadhak_profile.advance_profile.build_advance_profile_photograph(sadhak_profile_params[:advance_profile_attributes][:advance_profile_photograph_attributes]).save!

          @sadhak_profile.advance_profile.try(:advance_profile_identity_proof) || @sadhak_profile.advance_profile.build_advance_profile_identity_proof(sadhak_profile_params[:advance_profile_attributes][:advance_profile_identity_proof_attributes]).save!

          @sadhak_profile.advance_profile.try(:advance_profile_address_proof) || @sadhak_profile.advance_profile.build_advance_profile_address_proof(sadhak_profile_params[:advance_profile_attributes][:advance_profile_address_proof_attributes]).save!

        when :special_other_infos

          @sadhak_profile.special_event_sadhak_profile_other_infos.build(sadhak_profile_params[:special_event_sadhak_profile_other_infos_attributes]['0'])
          @sadhak_profile.save!(sadhak_profile_params)
            

        else

          update_model(@sadhak_profile.send(params[:id]) || @sadhak_profile.send("build_" + params[:id]), sadhak_profile_params[(params[:id] + "_attributes").to_sym])

        end
      jump_to(next_step)
      
    rescue Exception => e

      flash[:alert] = e.message
      redirect_back(fallback_location: proc { root_path }) and return
      
    end

    render_wizard

  end

  def create_other_spiritual_association

    begin

      @other_spiritual_association = @sadhak_profile.other_spiritual_associations.build(other_spiritual_association_params)
      @other_spiritual_association.save!
      
    rescue Exception => e

      @message = e.message
      
    end
    
    respond_to do |format|
      format.js
    end

  end

  def delete_other_spiritual_association

    begin

      raise "No Associated Object Found " if params[:other_spiritual_association_id].blank?

      @other_spiritual_association_id = params[:other_spiritual_association_id]

      OtherSpiritualAssociation.find(@other_spiritual_association_id.to_i).destroy!
      
    rescue Exception => e

      @message = e.message
      
    end

    respond_to do |format|
      format.js
    end

  end

  def create_sadhak_profile_attended_shivir

    begin

      @sadhak_profile_attended_shivir = @sadhak_profile.sadhak_profile_attended_shivirs.build(sadhak_profile_attended_shivir_params)
      @sadhak_profile_attended_shivir.save!
      
    rescue Exception => e

      @message = e.message
      
    end

    respond_to do |format|
      format.js
    end

  end

  def delete_sadhak_profile_attended_shivir

    begin

      raise "No Associated Object Found " if params[:sadhak_profile_attended_shivir_id].blank?

      @sadhak_profile_attended_shivir_id = params[:sadhak_profile_attended_shivir_id]

      SadhakProfileAttendedShivir.find(@sadhak_profile_attended_shivir_id.to_i).destroy!
      
    rescue Exception => e

      @message = e.message
      
    end

    respond_to do |format|
      format.js
    end

  end

  def finish_wizard_path
    finish_page_event_sadhak_profile_sadhak_profile_steps_path(@event, @sadhak_profile)
  end

  def finish_page
    # ActionCable.server.broadcast('add_sadhak_profiles', { add_sadhak_profile_token: session[:add_sadhak_profile_token] })
    # session.delete(:add_sadhak_profile_token)
  end

  private

  def set_sadhak_profile
    @sadhak_profile = SadhakProfile.find_by!(slug: params[:sadhak_profile_id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def sadhak_profile_params
    params.require(:sadhak_profile).permit(:name_of_guru, :spiritual_org_name, :status_notes, :event_id, :id, :username, :first_name, :last_name,:date_of_birth, :gender, :mobile, :email, address_attributes:[:id, :first_line, :second_line, :country_id , :state_id, :other_state, :city_id, :other_city, :postal_code], professional_detail_attributes:[:id, :highest_degree, :profession_id, :designation, :occupation, :name_of_organization, :professional_specialization, :personal_interests, :years_of_experience], spiritual_practice_attributes:[:id, :morning_sadha_duration_hours, :afternoon_sadha_duration_hours, :evening_sadha_duration_hours, :other_sadha_duration_hours, :sadhana_frequency_days_per_week, :frequency_period, frequent_sadhna_type_ids:[], physical_exercise_type_ids:[], shivyog_teaching_ids:[]], advance_profile_attributes:[:id, :faith, :any_legal_proceeding, :attended_any_shivir, :photo_id_proof_type_id, :photo_id_proof_number, :address_proof_type_id ,advance_profile_photograph_attributes:[:id, :name, :image_data_base64], advance_profile_identity_proof_attributes:[:id, :name], advance_profile_address_proof_attributes:[:id, :name]], medical_practitioners_profile_attributes:[:id, :current_professional_role, :interested_in_panel_discussion, :interested_in_volunteering, :medical_degree, :medical_practitioner_speciality_area_id, :other_role, :other_speciality, :practiced_integrative_health_care, :sadhak_profile_id, :work_enviroment], sadhak_seva_preference_attributes:[:id, :voluntary_organisation, :availability, :seva_preference, :expertise], spiritual_journey_attributes:[:id, :source_info_type_id, :sub_source_type_id, :first_event_attended, :first_event_attended_year, :first_event_attended_month, :reason_for_joining], special_event_sadhak_profile_other_infos_attributes: [:id, :father_name, :mother_name, :are_you_member_of_political_party, :political_party_name, :how_long_associated_with_shivyog, :yearly_renumaration, :languages, :are_you_taking_medication, :medication_details, :are_you_suffering_from_physical_or_mental_ailments, :ailment_details, :are_you_involved_in_any_litigation_cases, :case_details, :why_you_want_to_attend_this_shivir, :how_did_you_came_to_know_about_the_shivir, :would_you_like_to_participate_in_the_devine_mission_of_shivyog, :participation_details, :accepted_terms_and_conditions, :signature, :event_id, special_event_sadhak_profile_references_attributes: [:id, :sadhak_profile_id]], doctors_profile_attributes: [:medical_school, :education_country_id, :year_of_graduation, :area_of_speciality, :sub_speciality, :license_status, :license_state_id, :license_country_id, :primary_work_setting, :practice_place, :practice_state_id, :practice_country_id, :practice_years, :clinical_research, :hospital_affiliations, :professional_publications, :honors_and_awards, :sadhak_profile_id])
  end

    

  def aspect_feedback_params
    params.require(:aspect_feedback).permit!
  end

  def other_spiritual_association_params
    params.require(:other_spiritual_association).permit(:associated_since_month, :associated_since_year, :association_description, :duration_of_practice, :organization_name, :sadhak_profile_id)
  end

  def sadhak_profile_attended_shivir_params
    params.require(:sadhak_profile_attended_shivir).permit(:shivir_name, :place, :year, :month)
  end

  def update_model(model, updated_params)

    if model.try(:persisted?)

      existing_attributes = model.attributes.with_indifferent_access.select{ |k,v| v.present? }.except(:id).try(:keys)
      model.update!(updated_params.except(*existing_attributes))

    else

      model.class.new(model.attributes.merge(updated_params.as_json)).save!

    end

    @sadhak_profile.reload

  end

end
