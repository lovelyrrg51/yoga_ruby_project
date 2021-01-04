module Api::V1
  class ForumAttendanceDetailsController < BaseController
    before_action :set_forum_attendance_detail, only: [:show, :edit, :update, :destroy, :update_attendance, :edit_details]
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!, raise: false
    before_action :locate_collection, only: :index
  
    # GET /forum_attendance_details
    def index
      if params[:page].present?
        render json: @forum_attendance_details, serializer: PaginationSerializer
      else
        render json: @forum_attendance_details
      end
    end
  
    # GET /forum_attendance_details/1
    def show
      authorize @forum_attendance_detail
      render json: @forum_attendance_detail
    end
  
    # GET /forum_attendance_details/new
    def new
      @forum_attendance_detail = ForumAttendanceDetail.new
    end
  
    # GET /forum_attendance_details/1/edit
    def edit
    end
  
    # POST /forum_attendance_details
    def create
      @forum_attendance_detail = ForumAttendanceDetail.new(forum_attendance_detail_params)
  
      authorize @forum_attendance_detail
  
      if @forum_attendance_detail.save
        render json: @forum_attendance_detail
      else
        render json: {errors: @forum_attendance_detail.errors.full_messages}, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /forum_attendance_details/1
    def update
      authorize @forum_attendance_detail
  
      if @forum_attendance_detail.update(forum_attendance_detail_params)
        render json: @forum_attendance_detail
      else
        render json: {errors: @forum_attendance_detail.errors.full_messages}, status: :unprocessable_entity
      end
  
    end
  
    # DELETE /forum_attendance_details/1
    def destroy
      authorize @forum_attendance_detail
      @forum_attendance_detail.destroy
      render json: @forum_attendance_detail
    end
  
    def locate_collection
      if params[:page].present?
        @forum_attendance_details = ForumAttendanceDetailPolicy::Scope.new(current_user, ForumAttendanceDetail).resolve(filtering_params).order('forum_attendance_details.conducted_on DESC').includes(:forum_attendances, :digital_asset, { sy_club: [{ address: [:db_city, :db_state, :db_country] }] }).page(params[:page]).per(params[:per_page])
      else
        @forum_attendance_details = ForumAttendanceDetailPolicy::Scope.new(current_user, ForumAttendanceDetail).resolve(filtering_params).order('forum_attendance_details.conducted_on DESC').includes(:forum_attendances, :digital_asset, { sy_club: [{ address: [:db_city, :db_state, :db_country] }] })
      end
    end
  
    # PUT /forum_attendance_details/1/update_attendance
    def update_attendance
      
      authorize @forum_attendance_detail
  
      begin
  
        notifications = []
  
        ActiveRecord::Base.transaction do
  
          raise @forum_attendance_detail.errors.full_messages.first unless @forum_attendance_detail.increment(:edit_count) && @forum_attendance_detail.save
  
          sadhak_profile_ids = update_attendance_params.fetch(:sadhak_profile_ids, []).map(&:to_i)
  
          @forum_attendance_detail.forum_attendances.where(is_current_forum_member: true).each do |forum_attendance_model|
  
            is_attended = sadhak_profile_ids.include?(forum_attendance_model.sadhak_profile_id)
  
            notifications << ActiveSupport::HashWithIndifferentAccess.new(forum_attendance_model.attributes).merge({is_attended: is_attended}) if forum_attendance_model.is_attended != is_attended
  
            raise forum_attendance_model.errors.full_messages.first unless forum_attendance_model.update(is_attended: is_attended)
  
          end
  
          outsider_sadhak_profile_ids = update_attendance_params.fetch(:outsider_sadhak_profile_ids, []).collect(&:to_i)
  
          all_outsider_sadhak_profile_ids = @forum_attendance_detail.forum_attendances.where(is_current_forum_member: false).pluck(:sadhak_profile_id)
  
          deletable_outsider_sadhak_profile_ids = all_outsider_sadhak_profile_ids - outsider_sadhak_profile_ids
  
          buildable_outsider_sadhak_profile_ids = outsider_sadhak_profile_ids - all_outsider_sadhak_profile_ids
  
          @forum_attendance_detail.forum_attendances.where(sadhak_profile_id: deletable_outsider_sadhak_profile_ids, is_current_forum_member: false).each do |forum_attendance|
  
            notifications << ActiveSupport::HashWithIndifferentAccess.new(forum_attendance.attributes).merge({is_attended: false})
  
            forum_attendance.destroy
  
          end
  
          buildable_outsider_sadhak_profile_ids.each do |sadhak_profile_id|
  
            forum_attendance = @forum_attendance_detail.forum_attendances.build(sadhak_profile_id: sadhak_profile_id, is_attended: true)
            
            raise forum_attendance.errors.full_messages.first unless forum_attendance.save
  
            notifications << ActiveSupport::HashWithIndifferentAccess.new(forum_attendance.attributes)
  
          end
  
        end
  
        # Commented as requested by Sandeep Ji. (Email: Forum attendance module Dated: Aug 10, 2017)
        # notifications.each do |forum_attendance|
  
        #   ForumAttendance.delay.notify_attendance_updates(forum_attendance)
  
        # end
  
        # Commented as requested by Sandeep Ji. (Email: Forum attendance module Dated: Aug 10, 2017)
        # @forum_attendance_detail.delay.notify_board_members_about_attendance_edit
        
      rescue Exception => e
        message = e.message
      end
      if message.present?
        render json: {errors: [message]}, status: :unprocessable_entity
      else
        render json: {success: ['Information Saved Successfully.']}
      end
  
    end
  
    # GET /forum_attendance_details/1/edit_details
    def edit_details
      
      authorize @forum_attendance_detail
  
      forum_attendance_details = @forum_attendance_detail.versions.collect{ |fad_v| fad_v.reify }
  
      forum_attendance_details << @forum_attendance_detail
  
      details = forum_attendance_details.drop(1).collect.with_index do |fad, i|
  
        "#{i + 1}#{ActiveSupport::Inflector.ordinal(i + 1)} marked by #{fad.who_last_updated_syid}/#{fad.who_last_updated_full_name} on #{fad.updated_at.strftime('%d-%m-%Y')}/#{fad.updated_at.strftime('%r')}"
  
      end
  
      render json: { forum_attendance_details:  details }
  
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_forum_attendance_detail
        @forum_attendance_detail = ForumAttendanceDetail.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def forum_attendance_detail_params
        params.require(:forum_attendance_detail).permit(:digital_asset_id, :sy_club_id, :conducted_on, :venue)
      end
  
      def filtering_params
        params.slice(:sy_club_id, :digital_asset_id, :conducted_on).select{|k, v| v.present? }
      end
  
      def update_attendance_params
        params.require(:forum_attendance_detail).permit(sadhak_profile_ids: [], outsider_sadhak_profile_ids: [])
      end
  end
end
