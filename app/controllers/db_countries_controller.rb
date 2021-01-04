class DbCountriesController < ApplicationController

  before_action :set_db_country, only:[:destroy, :update, :edit]
  before_action :authenticate_user!

  def index

    @db_country = DbCountry.new

    authorize(@db_country)

    if filtering_params.present?

      locate_collections

    else
      
      @db_countries = DbCountry.page(params[:page]).per(params[:per_page])

    end

  end

  def create
    begin
      @db_country = DbCountry.new(db_country_params)

      authorize(@db_country)
      if @db_country.save
        flash[:success] = "Country was successfully created."
      else
        flash[:error] = @db_country.errors.full_messages.first
      end
    rescue Exception => e
      flash[:error] = e.message
    end

    redirect_to db_countries_path

  end

  def edit

    authorize(@db_country)

  end

  def update

    authorize(@db_country)

    if @db_country.update(db_country_params)
      flash[:success] = "Country was successfully updated."
    else
      flash[:error] = @db_country.errors.full_messages.first
    end

    redirect_to db_countries_path

  end

  def destroy

    authorize(@db_country)

    begin

      @db_country.destroy
      
    rescue Exception => e

      message = e
      
    end

    if message.present?
      flash[:error] = message
    else
      flash[:notice] = "Country was successfully destroyed."
    end
    
    redirect_to db_countries_path

  end



  def country_index_for_state

    authorize DbCountry

    if filtering_params.present?
      locate_collections
    else
      @db_countries = DbCountry.page(params[:page]).per(params[:per_page])
    end

  end

  def country_index_for_state_city

    authorize DbCountry

    if filtering_params.present?
      locate_collections
    else
      @db_countries = DbCountry.page(params[:page]).per(params[:per_page])
    end

  end

  private

  def locate_collections
    @db_countries = DbCountryPolicy::Scope.new(current_user, DbCountry).resolve(filtering_params).order('db_countries.name ASC').page(params[:page]).per(params[:per_page])
  end

  def filtering_params
    params.slice(:country_name)
  end

  def db_country_params
    params.require(:db_country).permit(:name, :telephone_prefix)
  end

  def set_db_country
    @db_country = DbCountry.find(params[:id])
  end

end
