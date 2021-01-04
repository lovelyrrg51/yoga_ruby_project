module Api::V1
  class SpecialEventSadhakProfileOtherInfosController < BaseController
    before_action :set_special_event_sadhak_profile_other_info, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, only: []
    before_action :locate_collection, only: :index
    respond_to :json
  
    # GET /special_event_sadhak_profile_other_infos
    def index
      render json: @special_event_sadhak_profile_other_infos
    end
  
    # GET /special_event_sadhak_profile_other_infos/1
    def show
    end
  
    # GET /special_event_sadhak_profile_other_infos/new
    def new
      @special_event_sadhak_profile_other_info = SpecialEventSadhakProfileOtherInfo.new
    end
  
    # GET /special_event_sadhak_profile_other_infos/1/edit
    def edit
    end
  
    # POST /special_event_sadhak_profile_other_infos
    def create
      @special_event_sadhak_profile_other_info = SpecialEventSadhakProfileOtherInfo.where(sadhak_profile_id: special_event_sadhak_profile_other_info_params[:sadhak_profile_id], event_id: special_event_sadhak_profile_other_info_params[:event_id], event_order_line_item_id: nil).last
  
      begin
        if @special_event_sadhak_profile_other_info.present?
          @special_event_sadhak_profile_other_info.update!(special_event_sadhak_profile_other_info_params.merge(skip_validations: true))
        else
          @special_event_sadhak_profile_other_info = SpecialEventSadhakProfileOtherInfo.new(special_event_sadhak_profile_other_info_params)
          @special_event_sadhak_profile_other_info.save!
        end
      rescue Exception => e
        message = e.message.split(':').last
      end
  
      unless message.present?
        render json: {success: {success: ['Information saved successfully.']}}
      else
        render json: {errors: {error: [message]}}, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /special_event_sadhak_profile_other_infos/1
    def update
      if @special_event_sadhak_profile_other_info.update(special_event_sadhak_profile_other_info_params)
        render json: @special_event_sadhak_profile_other_info
      else
        render json: {errors: {error: @special_event_sadhak_profile_other_info.errors.full_messages}}, status: :unprocessable_entity
      end
    end
  
    def update_details
      begin
        update_details_params[:sadhak_profile_ids].each do |sadhak_profile_id|
          @special_event_sadhak_profile_other_info = SpecialEventSadhakProfileOtherInfo.where(sadhak_profile_id: sadhak_profile_id, event_id: update_details_params[:event_id], event_order_line_item_id: nil).order('created_at DESC').first
  
          raise "SY#{sadhak_profile_id} other info not found." unless @special_event_sadhak_profile_other_info.present?
  
          raise @special_event_sadhak_profile_other_info.errors.full_messages.first unless @special_event_sadhak_profile_other_info.update(update_details_params.except(:sadhak_profile_ids, :event_id))
        end
      rescue Exception => e
        message = e.message
      end
  
      unless message.present?
        render json: {success: {success: ['Information saved successfully.']}}
      else
        render json: {errors: {error: [message]}}, status: :unprocessable_entity
      end
    end
  
    # DELETE /special_event_sadhak_profile_other_infos/1
    def destroy
      @special_event_sadhak_profile_other_info.destroy
      render head :no_content
    end
  
    def locate_collection
      @special_event_sadhak_profile_other_infos = SpecialEventSadhakProfileOtherInfoPolicy::Scope.new(current_user, SpecialEventSadhakProfileOtherInfo).resolve(filtering_params)
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_special_event_sadhak_profile_other_info
        @special_event_sadhak_profile_other_info = SpecialEventSadhakProfileOtherInfo.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def special_event_sadhak_profile_other_info_params
        params.require(:special_event_sadhak_profile_other_info).permit(:sadhak_profile_id, :event_id, :father_name, :mother_name, :are_you_member_of_political_party, :political_party_name, :how_long_associated_with_shivyog, :yearly_renumaration, :languages, :are_you_taking_medication, :medication_details, :are_you_suffering_from_physical_or_mental_ailments, :ailment_details, :are_you_involved_in_any_litigation_cases, :case_details, :why_you_want_to_attend_this_shivir, :how_did_you_came_to_know_about_the_shivir, :would_you_like_to_participate_in_the_devine_mission_of_shivyog, :participation_details, :sadhak_profile_ids, sadhak_profile_ids: [])
      end
  
      def filtering_params
        params.slice(:sadhak_profile_id, :event_id)
      end
  
      def update_details_params
        params.require(:special_event_sadhak_profile_other_info).permit(:sadhak_profile_ids, :event_id, :accepted_terms_and_conditions, :signature, sadhak_profile_ids: [], accepted_terms_and_conditions: [])
      end
  end
end
