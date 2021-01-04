class CollectionEventTypeAssociationsController < ApplicationController
    before_action :set_collection_event_type_association, only: [:update]

    def update
        begin
            @collection_event_type_association.update!(collection_event_type_association_params)
        rescue Exception => e
            @error = true
            @message = e.message
        end
        @error ? flash[:alert] = @message : flash[:success] = "Collection is successfully updated."
        redirect_to shivir_collections_access_collections_path
    end

    private

    def set_collection_event_type_association
        @collection_event_type_association = CollectionEventTypeAssociation.find(params[:id])
    end

    def collection_event_type_association_params
        params.require(:collection_event_type_association).permit(:id, :sadhak_profile_ids, :collection_id, :event_type_id)
    end
end