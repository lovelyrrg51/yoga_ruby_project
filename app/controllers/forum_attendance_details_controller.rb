class ForumAttendanceDetailsController < ApplicationController
before_action :set_forum_attendance_detail, only: [:show, :edit, :update, :update_attendance, :search_member_from_other_forum]
before_action :authenticate_user!
before_action :set_sy_club, only: [:forum_attendance, :index, :show, :edit]
before_action :set_digital_asset, only: [:index, :show, :edit]


def forum_attendance
  authorize :forum_attendance_detail
  languages = @sy_club.languages
  @digital_assets =  DigitalAsset.joins(:collection).where(collections: {collection_type: 0}).select{ |asset| languages.include?(asset.language.to_s.downcase) && ((asset.published_on)..(asset.published_on + 4.weeks)).include?(Date.today)}
end

def index
  @forum_attendance_detail = @sy_club.forum_attendance_details.new(digital_asset_id: @digital_asset.id, conducted_on: Date.current)
  authorize(@forum_attendance_detail)
  @forum_attendance_details = @sy_club.forum_attendance_details.where(digital_asset_id: @digital_asset.id, conducted_on: (@digital_asset.published_on - 1)..(@digital_asset.published_on + 4.weeks)).includes(:sy_club, :digital_asset, :who_last_updated_sadhak_profile)
end

def show
  authorize(@forum_attendance_detail)
  begin
    ApplicationRecord.transaction do
      @sy_club.sy_club_members.approve.includes(:event_registration).each do |member|
        @forum_attendance_detail.forum_attendances.find_or_create_by(sy_club_member_id: member.id, sadhak_profile_id: member.sadhak_profile_id, forum_attendance_detail_id: @forum_attendance_detail.id, is_current_forum_member: true)
      end
    end
  rescue SyException => e
    error = e.message
  rescue Exception => e
    error = e.message
  end
  flash[:error] = error if error.present?
  @forum_attendance_detail.forum_attendances.reload.includes(:sadhak_profile)
  @all_present = @forum_attendance_detail.current_forum_attendances.map(&:is_attended).include?(false) ? false : true
end

def edit
end

def create
  @forum_attendance_detail = ForumAttendanceDetail.new(forum_attendance_detail_params)
  authorize(@forum_attendance_detail)
  if @forum_attendance_detail.save
  	flash[:success] = "Attendance details has been created."
  else
  	flash[:error] = @forum_attendance_detail.errors.full_messages.first
  end
  redirect_back(fallback_location: root_path)
end

def update
  authorize(@forum_attendance_detail)
  begin
     ActiveRecord::Base.transaction do
      if @forum_attendance_detail.update(forum_attendance_detail_params)
        flash[:success] = "Forum Attendance Detail has been successfully updated."
      else
        raise @forum_attendance_detail.errors.full_messages.first
      end
    end
  rescue SyException => e
    flash[:error] = e.message
  rescue Exception => e
    flash[:error] = e.message
  end
  redirect_back(fallback_location:  root_path)
end

def update_attendance
  last_updated_at_before_update = @forum_attendance_detail.updated_at
    begin
     ActiveRecord::Base.transaction do
      if @forum_attendance_detail.update(update_attendance_params)
       
        @forum_attendance_detail.increment!(:edit_count) unless last_updated_at_before_update === @forum_attendance_detail.reload.updated_at
        flash[:success] = "Forum Attendance has been uccessfully updated."
      else
        raise @forum_attendance_detail.errors.full_messages.first
      end
    end
  rescue SyException => e
    flash[:error] = e.message
  rescue Exception => e
    flash[:error] = e.message
  end
  redirect_back(fallback_location:  root_path)
end

def search_member_from_other_forum
  begin
    @sadhak_profile = SadhakProfile.filter(params.slice(:first_name, :syid).select!{ |k,v| v.present? }).includes(:sy_club_members, :sy_clubs).first
    raise SyException, "No Sadhak Profile found" unless @sadhak_profile.present?
    raise SyException, "SadhakProfile is not a forum member." unless @sadhak_profile.active_club_ids.size > 0
    raise SyException, "SadhakProfile can not in more than one forum member." if @sadhak_profile.active_club_ids.size > 1

    raise SyException, "SadhakProfile is already added to the list." if @sadhak_profile.active_club_ids.include?(params[:sy_club_id].to_i)
    
    raise SyException, "SadhakProfile is already added to the list." if @forum_attendance_detail.forum_attendances.pluck(:sadhak_profile_id).include?(@sadhak_profile.id)

    raise SyException, "SadhakProfile is not a forum member." unless @sadhak_profile.active_club_ids.size > 0

    degital_assets_forum_attendance_detail_ids = ForumAttendanceDetail.where(digital_asset_id: params[:digital_asset_id], sy_club_id: @sadhak_profile.active_club.id).ids.uniq

    forum_attendance = ForumAttendance.where(sadhak_profile_id: @sadhak_profile.id, forum_attendance_detail_id: degital_assets_forum_attendance_detail_ids).last

    raise SyException, "Attendance already marked in Forum #{@sadhak_profile.active_forum_name} on #{forum_attendance.created_at.strftime('%b %d, %Y')}" if forum_attendance.present?
  rescue SyException => e
    @error = e.message
  end
end

def absent_members_details
  @forum_attendances = ForumAttendance.where(id: params[:attendance_ids]).includes(:sadhak_profile)
end

private
  def locate_collection
      @forum_attendance_details = ForumAttendanceDetailPolicy::Scope.new(current_user, ForumAttendanceDetail).resolve(filtering_params).order('forum_attendance_details.conducted_on DESC').includes(:forum_attendances, :digital_asset, { sy_club: [{ address: [:db_city, :db_state, :db_country] }] }).page(params[:page]).per(params[:per_page])
  end

  def set_forum_attendance_detail
    @forum_attendance_detail = ForumAttendanceDetail.find(params[:id] || params[:forum_attendance_detail_id])
  end

  def update_attendance_params
    params.require(:forum_attendance_detail).permit(:digital_asset_id, :sy_club_id, :conducted_on, :venue, :conducted_on_in_time, current_forum_attendances_attributes: [:is_attended, :id, :sadhak_profile_id, :sy_club_member_id, :_destroy ,:is_current_forum_member, :last_updated_by], other_forum_attendances_attributes: [:is_attended, :id, :sadhak_profile_id, :sy_club_member_id ,:is_current_forum_member, :last_updated_by, :_destroy])
  end  

  def forum_attendance_detail_params
    params.require(:forum_attendance_detail).permit(:digital_asset_id, :sy_club_id, :conducted_on, :venue, :conducted_on_in_time, :creator_id)
  end

  def filtering_params
    params.slice(:sy_club_id, :digital_asset_id, :conducted_on).select{|k, v| v.present? }
  end

  def set_sy_club
  	@sy_club = SyClub.find(params[:sy_club_id])
  end

  def set_digital_asset
  	@digital_asset = DigitalAsset.find(params[:digital_asset_id])
  end
end
