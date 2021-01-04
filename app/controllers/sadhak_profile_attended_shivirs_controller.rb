class SadhakProfileAttendedShivirsController < ApplicationController

  before_action :set_sadhak_profile_attended_shivir, only:[:update, :destroy]
  before_action :set_sadhak_profile, only:[:create]
  before_action :authenticate_user!

  def create

    sadhak_profile_attended_shivir = @sadhak_profile.sadhak_profile_attended_shivirs.build(sadhak_profile_attended_shivir_params)
    
    if sadhak_profile_attended_shivir.save

      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:sadhak_profile_attended_shivir_sp_accordion_id])

    else

      flash[:alert] = 'Spiritual is not created'
      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:sadhak_profile_attended_shivir_sp_accordion_id])

    end

  end

  def update

    if @sadhak_profile_attended_shivir.update(sadhak_profile_attended_shivir_params)

      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:sadhak_profile_attended_shivir_sp_accordion_id])

    else

      flash[:alert] = 'Spiritual is not updated'
      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:sadhak_profile_attended_shivir_sp_accordion_id])

    end

  end

  def destroy

    if @sadhak_profile_attended_shivir.destroy

      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:sadhak_profile_attended_shivir_sp_accordion_id])

    else

      flash[:alert] = 'Spiritual is not destroyed'
      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:sadhak_profile_attended_shivir_sp_accordion_id])

    end

  end

  private 

  def sadhak_profile_attended_shivir_params
    params.require(:sadhak_profile_attended_shivir).permit(:shivir_name, :place, :year, :month)
  end

  def set_sadhak_profile_attended_shivir
    @sadhak_profile_attended_shivir = SadhakProfileAttendedShivir.find_by_id(params[:id])    
  end

  def set_sadhak_profile
    @sadhak_profile = SadhakProfile.find(params[:sadhak_profile_id])
  end

end
