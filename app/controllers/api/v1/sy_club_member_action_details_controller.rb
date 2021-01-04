module Api::V1
  class SyClubMemberActionDetailsController < BaseController
    before_action :set_sy_club_member_action_detail, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: []
    before_action :locate_collection, only: [:index]
    skip_before_action :verify_authenticity_token, only: []
    respond_to :json
  
    # GET /sy_club_member_action_details
    def index
      render json: @sy_club_member_action_details
    end
  
    # GET /sy_club_member_action_details/1
    def show
      render json: @sy_club_member_action_detail
    end
  
    # GET /sy_club_member_action_details/new
    def new
      render json: {}
    end
  
    # GET /sy_club_member_action_details/1/edit
    def edit
      render json: {}
    end
  
    # POST /sy_club_member_action_details
    def create
      @sy_club_member_action_detail = SyClubMemberActionDetail.new(sy_club_member_action_detail_params)
      authorize @sy_club_member_action_detail
      if @sy_club_member_action_detail.save
        render json: @sy_club_member_action_detail
      else
        render json: @sy_club_member_action_detail.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_member_action_details/1
    def update
      authorize @sy_club_member_action_detail
      if @sy_club_member_action_detail.update(sy_club_member_action_detail_params)
        render json: @sy_club_member_action_detail
      else
        render json: @sy_club_member_action_detail.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_member_action_details/1
    def destroy
      authorize @sy_club_member_action_detail
      if @sy_club_member_action_detail.update(is_deleted: true)
        render json: @sy_club_member_action_detail
      else
        render json: @sy_club_member_action_detail.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    def locate_collection
      @sy_club_member_transfers = SyClubMemberActionDetailPolicy::Scope.new(current_user, SyClubMemberActionDetail.preloaded_data).resolve(filtering_params)
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_sy_club_member_action_detail
      @sy_club_member_action_detail = SyClubMemberActionDetail.find(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def sy_club_member_action_detail_params
      params.require(:sy_club_member_action_detail).permit(:from_sy_club_member_id, :to_sy_club_member_id, :from_event_registration_id, :to_event_registration_id, :reason, :is_deleted, :status)
    end
  
    def filtering_params
      params.slice(:sadhak_profile_id, :from_club_id, :to_club_id, :status, :requester_id, :responder_id)
    end
  
  end
end
