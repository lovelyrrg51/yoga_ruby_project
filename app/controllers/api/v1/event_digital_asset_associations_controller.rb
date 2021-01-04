module Api::V1
  class EventDigitalAssetAssociationsController < BaseController
    before_action :set_event_digital_asset_association, only: [:show, :edit, :update, :destroy]
  
    # GET /event_digital_asset_associations
    # GET /event_digital_asset_associations.json
    def index
      @event_digital_asset_associations = EventDigitalAssetAssociation.all
    end
  
    # GET /event_digital_asset_associations/1
    # GET /event_digital_asset_associations/1.json
    def show
    end
  
    # GET /event_digital_asset_associations/new
    def new
      @event_digital_asset_association = EventDigitalAssetAssociation.new
    end
  
    # GET /event_digital_asset_associations/1/edit
    def edit
    end
  
    # POST /event_digital_asset_associations
    # POST /event_digital_asset_associations.json
    def create
      @event_digital_asset_association = EventDigitalAssetAssociation.new(event_digital_asset_association_params)
  
      respond_to do |format|
        if @event_digital_asset_association.save
          format.html { redirect_to @event_digital_asset_association, notice: 'Event digital asset association was successfully created.' }
          format.json { render :show, status: :created, location: @event_digital_asset_association }
        else
          format.html { render :new }
          format.json { render json: @event_digital_asset_association.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /event_digital_asset_associations/1
    # PATCH/PUT /event_digital_asset_associations/1.json
    def update
      respond_to do |format|
        if @event_digital_asset_association.update(event_digital_asset_association_params)
          format.html { redirect_to @event_digital_asset_association, notice: 'Event digital asset association was successfully updated.' }
          format.json { render :show, status: :ok, location: @event_digital_asset_association }
        else
          format.html { render :edit }
          format.json { render json: @event_digital_asset_association.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /event_digital_asset_associations/1
    # DELETE /event_digital_asset_associations/1.json
    def destroy
      @event_digital_asset_association.destroy
      respond_to do |format|
        format.html { redirect_to event_digital_asset_associations_url, notice: 'Event digital asset association was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_digital_asset_association
        @event_digital_asset_association = EventDigitalAssetAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_digital_asset_association_params
        params.require(:event_digital_asset_association).permit(:event_id, :digital_asset_id)
      end
  end
end
