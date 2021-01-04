class EventOrderLineItemsController < ApplicationController
    before_action :authenticate_user!, except: []
    before_action :set_event_order, only: [:destroy]
    before_action :set_event_order_line_item, only: [:destroy]

    def new
    end

    def edit
    end

    def create
    end

    def update
    end

    def destroy
        begin
            @event_order_line_item.destroy!
        rescue Exception => e
            message = e.message
        end
        message.present? ? flash[:alert] = message : flash[:success] = "Event Order Line Item is destroyed."
        redirect_back(fallback_location: proc { root_path })
    end

    private

    def set_event_order
        @event_order = EventOrder.find(params[:event_order_id])
    end

    def set_event_order_line_item
        @event_order_line_item = EventOrderLineItem.find(params[:id])
    end
end