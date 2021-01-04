class OtherSpiritualAssociationsController < ApplicationController

  before_action :set_other_spiritual_association, only:[:update, :destroy]
  before_action :set_sadhak_profile, only:[:create]
  before_action :authenticate_user!

  def create

    other_spiritual_association = @sadhak_profile.other_spiritual_associations.build(other_spiritual_association_params)
    authorize(other_spiritual_association)
    
    if other_spiritual_association.save

      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:other_spiritual_association_sp_accordion_id])

    else

      flash[:alert] = 'Spiritual is not created'
      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:other_spiritual_association_sp_accordion_id])

    end

  end

  def update

    authorize(@other_spiritual_association)
    if @other_spiritual_association.update(other_spiritual_association_params)

      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:other_spiritual_association_sp_accordion_id])

    else

      flash[:alert] = 'Spiritual is not updated'
      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:other_spiritual_association_sp_accordion_id])

    end

  end

  def destroy

    authorize(@other_spiritual_association)

    if @other_spiritual_association.destroy

      redirect_to edit_sadhak_profile_path(params[:sadhak_profile_id], sp_accordion_id: params[:other_spiritual_association_sp_accordion_id])

    else

      flash[:alert] = 'Spiritual is not destroyed'
      redirect_to edit_sadhak_profile_path(params[:other_spiritual_association][:sadhak_profile_id], sp_accordion_id: params[:other_spiritual_association_sp_accordion_id])

    end

  end

  private 

  def other_spiritual_association_params
    params.require(:other_spiritual_association).permit(:associated_since_month, :associated_since_year, :association_description, :duration_of_practice, :organization_name, :sadhak_profile_id)
  end

  def set_other_spiritual_association
    @other_spiritual_association = OtherSpiritualAssociation.find_by_id(params[:id])    
  end

  def set_sadhak_profile
    @sadhak_profile = SadhakProfile.find(params[:sadhak_profile_id])
  end

end