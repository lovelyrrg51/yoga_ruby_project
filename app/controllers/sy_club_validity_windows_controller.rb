class SyClubValidityWindowsController < ApplicationController

  before_action :set_sy_club_validity_window, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  add_breadcrumb "Forum Membership Validite", :sy_club_validity_windows_path

  def index

    authorize(SyClubValidityWindow)

    @sy_club_validity_windows = SyClubValidityWindow.all

  end

  def new

    @sy_club_validity_window = SyClubValidityWindow.new

    authorize(@sy_club_validity_window)

    add_breadcrumb 'New Validite Window'

  end

  def edit

    authorize(@sy_club_validity_window)

    add_breadcrumb "#{@sy_club_validity_window.club_reg_start_date} - #{@sy_club_validity_window.club_reg_end_date}", Proc.new{ edit_sy_club_validity_window_path(@sy_club_validity_window) }

  end

  def create

    @sy_club_validity_window = SyClubValidityWindow.new(sy_club_validity_window_params)

    authorize(@sy_club_validity_window)

    if @sy_club_validity_window.save
      flash[:success] = "Sy Club validity Window was successfully created."
    else
      flash[:error] = @sy_club_validity_window.errors.full_messages.first
    end

    redirect_to sy_club_validity_windows_path

  end

  def update

    authorize(@sy_club_validity_window)

    if @sy_club_validity_window.update(sy_club_validity_window_params)
      flash[:notice] = "Sy Club validity Window was successfully updated."
    else
      flash[:error] = @sy_club_validity_window.errors.full_messages.first
    end

    redirect_to sy_club_validity_windows_path

  end


  def destroy

    authorize(@sy_club_validity_window)

    if @sy_club_validity_window.destroy
      flash[:notice] = "Sy Club validity Window was successfully destroyed."
    else
      flash[:error] = @sy_club_validity_window.errors.full_messages.first
    end
    
    redirect_to sy_club_validity_windows_path

  end


  private

  def set_sy_club_validity_window
    @sy_club_validity_window = SyClubValidityWindow.find(params[:id])
  end

  def sy_club_validity_window_params
      params.require(:sy_club_validity_window).permit(:club_reg_start_date, :club_reg_end_date, :membership_start_date, :membership_end_date)
  end

end
