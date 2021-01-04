class TicketTypesController < ApplicationController

  before_action :set_ticket_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @ticket_type = TicketType.new

    authorize(@ticket_type)

    if filtering_params.present?

      locate_collection

    else

      @ticket_types = TicketType.page(params[:page]).per(params[:per_page]).order('ticket_types.ticket_type ASC')

    end

  end

  def edit

    authorize(@ticket_type)

  end

  def create

    @ticket_type = TicketType.new(ticket_type_params)

    authorize(@ticket_type)

    if @ticket_type.save
      flash[:success] = "Ticket Group was successfully created."
    else
      flash[:error] = @ticket_type.errors.full_messages.first
    end

    redirect_to ticket_types_path

  end

  def update

    authorize(@ticket_type)

    if @ticket_type.update(ticket_type_params)
      flash[:success] = "Ticket Group was successfully updated."
    else
      flash[:error] = @ticket_type.errors.full_messages.first
    end

    redirect_to ticket_types_path

  end


  def destroy

    authorize(@ticket_type)

    if @ticket_type.destroy
      flash[:success] = "Ticket Group was successfully destroyed."
    else
      flash[:error] = @ticket_type.errors.full_messages.first
    end

    redirect_to ticket_types_path

  end

  private

  def locate_collection
    @ticket_types = TicketTypePolicy::Scope.new(current_user, TicketType).resolve(filtering_params).order('ticket_types.ticket_type ASC').page(params[:page]).per(params[:per_page])
  end

  def set_ticket_type
    @ticket_type = TicketType.find(params[:id])
  end

  def ticket_type_params
    params.require(:ticket_type).permit(:ticket_type, :ticket_group_id)
  end

  def filtering_params
    params.slice(:ticket_type_name, :ticket_group_name)
  end

end
