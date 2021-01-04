class TicketGroupsController < ApplicationController

  before_action :set_ticket_group, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @ticket_group = TicketGroup.new

    authorize(@ticket_group)

    if filtering_params.present?

      locate_collection

    else

    @ticket_groups = TicketGroup.page(params[:page]).per(params[:per_page]).order('ticket_groups.name ASC')  

    end

  end

  def edit

    authorize(@ticket_group)

  end

  def create

    @ticket_group = TicketGroup.new(ticket_group_params)

    authorize(@ticket_group)

    if @ticket_group.save
      flash[:success] = "Ticket Group was successfully created."
    else
      flash[:error] = @ticket_group.errors.full_messages.first
    end

    redirect_to ticket_groups_path

  end

  def update

    authorize(@ticket_group)

    if @ticket_group.update(ticket_group_params)
      flash[:success] = "Ticket Group was successfully updated."
    else
      flash[:error] = @ticket_group.errors.full_messages.first
    end

    redirect_to ticket_groups_path

  end


  def destroy

    authorize(@ticket_group)

    if @ticket_group.destroy
      flash[:success] = "Ticket Group was successfully destroyed."
    else
      flash[:error] = @ticket_group.errors.full_messages.first
    end

    redirect_to ticket_groups_path

  end

  private

  def locate_collection
    @ticket_groups = TicketGroupPolicy::Scope.new(current_user, TicketGroup).resolve(filtering_params).order('ticket_groups.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_ticket_group
    @ticket_group = TicketGroup.find(params[:id])
  end

  def ticket_group_params
      params.require(:ticket_group).permit(:name)
  end

  def filtering_params
    params.slice(:ticket_group_name)
  end

end
