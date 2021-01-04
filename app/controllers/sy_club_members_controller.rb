class SyClubMembersController < ApplicationController
  
  before_action :set_sy_club_member, only: [:info]

  def info
    respond_to do |format|
      format.js
    end
  end

  private

  def set_sy_club_member
    @sy_club_member = SyClubMember.find(params[:id])
  end
end