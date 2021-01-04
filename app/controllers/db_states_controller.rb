class DbStatesController < ApplicationController

	include DbStatesHelper

  before_action :locate_collection, only:[:index]
  before_action :set_db_country, only:[:new, :create, :index_for_admin, :edit, :update, :destroy, :state_index_for_city]
  before_action :set_db_state, only:[:destroy, :update, :edit]

	def index
        @changable_id = params[:changable_id]  if params[:changable_id].present?
        @states += DbState.other_state
        @telephone_prefix = @states.first.country.telephone_prefix

		respond_to  do |format|
			if @states.present?
				format.html
				format.js  {}
				format.json  { render :json => @states.collect{|s| {id: s.id, name: s.name}} || {} }
			else
				format.json  { render :json=> {} }
			end
		end		
	end

	def locate_collection
		@states = DbState.filter(filtering_params)
	end

  def index_for_admin

    @db_state = DbState.new

    authorize(@db_state)

    if filtering_params.present?

      @db_states = DbStatePolicy::Scope.new(current_user, DbState).resolve(filtering_params).order('db_states.name ASC').page(params[:page]).per(params[:per_page])

    else

      @db_states = DbState.where(country_id: @db_country.id).page(params[:page]).per(params[:per_page])

    end

  end

  def create

    @db_state = @db_country.states.new(db_state_params)

    authorize(@db_state)

    if @db_state.save
      flash[:success] = "State was successfully created."
    else
      flash[:error] = @db_state.errors.full_messages.first
    end

    redirect_to index_for_admin_db_country_db_states_path(@db_country)

  end

  def edit
    
    authorize(@db_state)

  end

  def update

    authorize(@db_state)

    if @db_state.update(db_state_params)
      flash[:success] = "State was successfully updated."
    else
      flash[:error] = @db_state.errors.full_messages.first
    end

    redirect_to index_for_admin_db_country_db_states_path(@db_country)

  end

  def destroy

    authorize(@db_state)

    begin

      @db_state.destroy
      
    rescue Exception => e

      message = e
      
    end

    if message.present?
      flash[:error] = message
    else
      flash[:success] = "State was successfully destroyed."
    end
    
    redirect_to index_for_admin_db_country_db_states_path(@db_country)

  end

  def state_index_for_city

    authorize DbState

    if filtering_params.present?
      @db_states = DbStatePolicy::Scope.new(current_user, DbState).resolve(filtering_params).order('db_states.name ASC').page(params[:page]).per(params[:per_page])
    else
      @db_states = DbState.where(country_id: @db_country.id).page(params[:page]).per(params[:per_page])
    end

  end

  private
  
  def filtering_params
    params.slice(:state_name, :db_country_id, :country_id)
  end

  def db_state_params
    params.require(:db_state).permit(:name, :telephone_prefix)
  end

  def set_db_state
    @db_state = DbState.find(params[:id])
  end

  def set_db_country
    @db_country = DbCountry.find(params[:db_country_id])
  end

end
