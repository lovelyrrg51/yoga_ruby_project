class RegistrationCentersController < ApplicationController

	include RegistrationCentersHelper

  before_action :set_registration_center_event, only: [:new, :edit, :create, :update]
  before_action :set_registration_center, only:[:edit, :update, :edit_for_admin, :update_for_admin, :destroy_for_admin]
  before_action :authenticate_user!

  def new
    authorize(:registration_center, :new?)

    @registration_center = RegistrationCenter.new

    @registration_centers = @event.registration_centers

  end

  def edit
    authorize(:registration_center, :edit?)

    @registration_centers = @event.registration_centers.where.not(id: @registration_center.id)
    
  end

  def create
    authorize(:registration_center, :create?)

  	@registration_center = RegistrationCenter.new(registration_center_params)

    if @registration_center.save
      
      flash[:notice] = 'Registration center was created successfully.'
    
    else
    
      flash[:alert] = @registration_center.errors.full_messages.first
    
    end
    
    redirect_to new_event_registration_center_path(@event)

  end

  def update
    authorize(:registration_center, :update?)

    if @registration_center.update(registration_center_params)
      
      flash[:notice] = 'Registration center was successfully updated.'
    
    else
      
      flash[:alert] = @registration_center.errors.full_messages.first
    
    end
    
    redirect_to new_event_registration_center_path(@event)

  end

  def index_for_admin

    @registration_center = RegistrationCenter.new

    authorize(@registration_center)

    if filtering_params.present?

      locate_collection

    else

      @registration_centers = RegistrationCenter.page(params[:page]).per(params[:per_page]).order('registration_centers.name ASC')

    end

  end

  def edit_for_admin

    authorize(@registration_center)

  end

  def create_for_admin

    @registration_center = RegistrationCenter.new(registration_center_params)

    authorize(@registration_center)

    if @registration_center.save
      flash[:success] = "Registration Center was successfully created."
    else
      flash[:error] = @registration_center.errors.full_messages.first
    end

    redirect_to index_for_admin_registration_centers_path

  end

  def update_for_admin

    authorize(@registration_center)

    if @registration_center.update(registration_center_params)
      flash[:success] = "Registration Center was successfully updated."
    else
      flash[:error] = @registration_center.errors.full_messages.first
    end

    redirect_to index_for_admin_registration_centers_path

  end


  def destroy_for_admin

    authorize(@registration_center)

    if @registration_center.destroy
      flash[:success] = "Registration Center was successfully destroyed."
    else
      flash[:error] = @registration_center.errors.full_messages.first
    end

    redirect_to index_for_admin_registration_centers_path

  end

  def locate_collection

    @registration_centers = RegistrationCenterPolicy::Scope.new(current_user, RegistrationCenter).resolve(filtering_params).order('registration_centers.name ASC').page(params[:page]).per(params[:per_page])

  end

  private

  def set_registration_center
  	@registration_center = RegistrationCenter.find(params[:id])
  end

  def registration_center_params
  	params.require(:registration_center).permit(:name, :is_cash_allowed, :start_date, :end_date, :event_ids, :user_ids, user_ids: [], event_ids: [])
  end

  def set_registration_center_event
    @event = Event.find(params[:event_id])
  end

  def filtering_params
    params.slice(:registration_center_name)
  end

end
