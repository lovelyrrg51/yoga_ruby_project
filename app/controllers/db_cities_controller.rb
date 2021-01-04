class DbCitiesController < ApplicationController

	include DbCitiesHelper

  before_action :locate_collection, only:[:index]
  before_action :set_db_country, only:[:new, :create, :index_for_admin, :edit, :update, :destroy]
  before_action :set_db_state, only:[:new, :create, :index_for_admin, :edit, :update, :destroy]
  before_action :set_db_city, only:[:destroy, :update, :edit]

	def index
		@changable_id = params[:changable_id] if params[:changable_id].present?
		@cities += DbCity.other_city
		respond_to  do |format|
			if @cities.present?
				format.html
				format.js  {}
				format.json  { render :json => @cities.collect{|s| {id: s.id, name: s.name}}}
			else
				format.json  { render :json=> {} }
			end
		end		
	end

	def locate_collection
		@cities = DbCity.filter(filtering_params)
	end

  def index_for_admin

    @db_city = DbCity.new

    authorize(@db_city)

    if filtering_params.present?

      @db_cities = DbCityPolicy::Scope.new(current_user, DbCity).resolve(filtering_params).order('db_cities.name ASC').page(params[:page]).per(params[:per_page])

    else

    @db_cities = DbCity.where("country_id = :country_id AND state_id =  :state_id", country_id: @db_country.id, state_id: @db_state.id).page(params[:page]).per(params[:per_page])

    end

  end

  def new

    @db_city = DbCity.new

    authorize(@db_city)

  end

  def create

    begin

      @db_city = @db_state.cities.new(db_city_params)

      authorize(@db_city)

      @db_city.country_id = @db_country.id

      if @db_city.save
        flash[:success] = "City was successfully created."
      else
        flash[:error] = @db_city.errors.full_messages.first
      end

      redirect_to index_for_admin_db_country_db_state_db_cities_path(@db_country, @db_state)
      
    rescue Exception => e

      flash[:error] = e.message
      redirect_back(fallback_location: proc { root_path })
      
    end

    

  end

  def edit
    
    authorize(@db_city)

  end

  def update

    authorize(@db_city)

    if @db_city.update(db_city_params)
      flash[:success] = "State was successfully updated."
    else
      flash[:error] = @db_city.errors.full_messages.first
    end

    redirect_to index_for_admin_db_country_db_state_db_cities_path(@db_country, @db_state)

  end

  def destroy

    authorize(@db_city)

    if @db_city.destroy
      flash[:success] = "City was successfully destroyed."
    else
      flash[:error] = @db_city.errors.full_messages.first
    end
    
    redirect_to index_for_admin_db_country_db_state_db_cities_path(@db_country, @db_state)

  end

  private

  def filtering_params
    params.slice(:city_name, :db_country_id, :db_state_id, :state_id)
  end

  def db_city_params
    params.require(:db_city).permit(:name)
  end

  def set_db_state
    @db_state = DbState.find(params[:db_state_id])
  end

  def set_db_city
    @db_city = DbCity.find(params[:id])
  end

  def set_db_country
    @db_country = DbCountry.find(params[:db_country_id])
  end

end
