module Api::V1::ShivyogClub
  class SyClubMembersController < ::Api::V1::BaseController
     before_action :authenticate_user!, except: [:index, :create, :show]
    before_action :set_sy_club_member, only: [:show, :edit, :update, :destroy]
    respond_to :json
    before_action :locate_collection, :only => :index
  
    # GET /sy_club_members
    def index
      render json: @sy_club_members
    end
  
    # GET /sy_club_members/1
    def show
    end
  
    # GET /sy_club_members/new
    def new
      @sy_club_member = SyClubMember.new
    end
  
    # GET /sy_club_members/1/edit
    def edit
    end
  
    # POST /sy_club_members
    def create
      @sy_club_member = SyClubMember.new(sy_club_member_params)
      if @sy_club_member.save
        render json: @sy_club_member
      else
        render json: @sy_club_member.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_members/1
    def update
      if @sy_club_member.update(sy_club_member_params)
        render json: @sy_club_member
      else
        render json: @sy_club_member.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_members/1
    def destroy
      if @sy_club_member.destroy
        render json: @sy_club_member
      else
        render json: @sy_club_member.errors, status: :unprocessable_entity
      end
    end
  
    def locate_collection
      if (params.has_key?("filter"))
        @sy_club_members = ::Api::V1::SyClubMemberPolicy::Scope.new(current_user, SyClubMember).resolve(filtering_params).includes(SyClubMember.includable_data)
      else
        @sy_club_members = policy_scope(SyClubMember).includes(SyClubMember.includable_data)
      end
    end
  
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_member
        @sy_club_member = SyClubMember.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_member_params
        params.require(:sy_club_member).permit(:sy_club_id, :sadhak_profile_id, :status, :sy_club_validity_window_id, :club_joining_date, :guest_email, :virtual_role)
      end
      def filtering_params
        params.slice(:sy_club_id)
      end
  end
end
