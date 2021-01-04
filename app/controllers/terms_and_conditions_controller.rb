class TermsAndConditionsController < ApplicationController

  def event_register
  end

  def demand_draft_payment
  end

  def cash_payment
  end

  def sy_event_company
    @sy_event_company = SyEventCompany.find_by_id(params[:sy_event_company_id])
  end

  def forum
  end

  def online_payment
  end
  
end
