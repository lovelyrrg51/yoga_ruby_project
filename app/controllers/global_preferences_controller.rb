class GlobalPreferencesController < ApplicationController

  before_action :set_global_preference, only:[:edit, :update]
  before_action :authenticate_user!

  def index

    authorize(GlobalPreference)

    @group_name = params[:group_name]

    @global_preferences = GlobalPreference.where(group_name: @group_name)

  end

  def edit

    authorize(@global_preference)

  end

  def update

    authorize(@global_preference)

    if @global_preference.update(global_preference_params)
      flash[:success] = "Global Preference is sucessfully updated."
    else
      flash[:error] = @global_preference.errors.full_messages.first
    end

    redirect_to global_preferences_path(group_name: @global_preference.group_name)

  end

  private

  def global_preference_params
    params.require(:global_preference).permit(:val)
  end

  def set_global_preference
    @global_preference = GlobalPreference.find(params[:id])
  end

end
