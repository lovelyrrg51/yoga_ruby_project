module Api::V1
  class ForumAttendancesController < BaseController
    before_action :set_forum_attendance, only: [:show, :edit, :update, :destroy]
    skip_before_action :authenticate_user!, except: [:create, :mark, :update, :destroy], raise: false
    before_action :locate_collection, only: :index
    before_action :set_forum_attendance_detail, only: [:create, :mark, :update, :index]
  
    # GET /forum_attendances
    def index
      if ForumAttendancePolicy.new(current_user, @forum_attendances.last).index?
        if params[:page].present?
          render json: @forum_attendances, serializer: PaginationSerializer
        else
          render json: @forum_attendances
        end
      else
        render json: []
      end
    end
  
    # GET /forum_attendances/1
    def show
      authorize @forum_attendance
      render json: @forum_attendance
    end
  
    # GET /forum_attendances/new
    def new
      @forum_attendance = ForumAttendance.new
    end
  
    # GET /forum_attendances/1/edit
    def edit
    end
  
    # POST /forum_attendances
    def create
  
      @forum_attendance = @forum_attendance_detail.forum_attendances.build(forum_attendance_params)
  
      authorize @forum_attendance
  
      if @forum_attendance.save
        render json: @forum_attendance
      else
        render json: {errors: @forum_attendance.errors.full_messages}, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /forum_attendances/1
    def update
      authorize @forum_attendance
  
      if @forum_attendance.update(forum_attendance_params.slice(:is_attended))
        # Commented as requested by Sandeep Ji. (Email: Forum attendance module Dated: Aug 10, 2017)
        # @forum_attendance.delay.notify_by_email
        # @forum_attendance.delay.notify_by_sms
        render json: @forum_attendance
      else
        render json: {errors: @forum_attendance.errors.full_messages}, status: :unprocessable_entity
      end
    end
  
    # DELETE /forum_attendances/1
    def destroy
      authorize @forum_attendance
      @forum_attendance.destroy
      render json: @forum_attendance
    end
  
    def locate_collection
      # Available sorting parameters are: sadhak_profiles.first_name, sadhak_profile_id, is_attended
      params[:sort] = 'sadhak_profiles.first_name, sadhak_profiles.last_name' unless params[:sort].present?
      if params[:page].present?
        @forum_attendances = ForumAttendancePolicy::Scope.new(current_user, ForumAttendance).resolve(filtering_params).joins(:sadhak_profile).order(ordering_params(params)).page(params[:page]).per(params[:per_page])
      else
        @forum_attendances = ForumAttendancePolicy::Scope.new(current_user, ForumAttendance).resolve(filtering_params).joins(:sadhak_profile).order(ordering_params(params))
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_forum_attendance
        @forum_attendance = ForumAttendance.find(params[:id])
      end
  
      def set_forum_attendance_detail
        @forum_attendance_detail = ForumAttendanceDetail.find(params[:forum_attendance_detail_id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def forum_attendance_params
        params.require(:forum_attendance).permit(:sadhak_profile_id, :is_attended)
      end
  
      def filtering_params
        params.slice(:sadhak_profile_id, :sy_club_member_id, :forum_attendance_detail_id, :is_attended, :is_current_forum_member, :syid, :first_name).select{ |k, v| v.present? }
      end
  end
end
