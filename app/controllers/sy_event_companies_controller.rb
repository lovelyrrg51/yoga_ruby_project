class SyEventCompaniesController < ApplicationController

  before_action :set_sy_event_company, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @sy_event_company = SyEventCompany.new

    address = @sy_event_company.build_address
    address.build_db_country
    address.build_db_state
    address.build_db_city

    authorize(@sy_event_company)

    if filtering_params.present?

      locate_collection

    else

      @sy_event_companies = SyEventCompany.page(params[:page]).per(params[:per_page]).order('sy_event_companies.name ASC')

    end

  end

  def edit

    authorize(@sy_event_company)
    unless @sy_event_company.address.present?
      address = @sy_event_company.build_address
      address.build_db_country
      address.build_db_state
      address.build_db_city
    end

  end

  def create

    @sy_event_company = SyEventCompany.new(sy_event_company_params)

    if @sy_event_company.save
      flash[:success] = "Company was successfully created."
    else
      flash[:error] = @sy_event_company.errors.full_messages.first
    end

    redirect_to sy_event_companies_path

  end

  def update

    if @sy_event_company.update(sy_event_company_params)
      flash[:success] = "Company was successfully updated."
    else
      flash[:error] = @sy_event_company.errors.full_messages.first
    end

    redirect_to sy_event_companies_path

  end


  def destroy

    if @sy_event_company.destroy
      flash[:success] = "Company was successfully destroyed."
    else
      flash[:error] = @sy_event_company.errors.full_messages.first
    end

    redirect_to sy_event_companies_path

  end

  def locate_collection

    if filtering_params.present?
      @sy_event_companies = SyEventCompanyPolicy::Scope.new(current_user, SyEventCompany).resolve(filtering_params).order('sy_event_companies.name ASC').page(params[:page]).per(params[:per_page])
    else
      @sy_event_companies = SyEventCompany.page(params[:page]).per(params[:per_page])

    end
  end

  private

  def set_sy_event_company
    @sy_event_company = SyEventCompany.find(params[:id])
  end

  def sy_event_company_params
      params.require(:sy_event_company).permit(:name, :llpin_number, :gstin_number, :terms_and_conditions, :automatic_invoice, :invoice_prefix, :receipt_prefix, :refund_prefix, :company_type, address_attributes:[:id, :first_line, :second_line, :city_id, :state_id, :postal_code, :country_id, :other_city, :other_state])
  end

  def filtering_params
    params.slice(:sy_event_company_name)
  end

end
