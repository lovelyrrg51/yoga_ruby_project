module Api::V1
  class OtherSpiritualAssociationsController < BaseController
    before_action :authenticate_user!, except: [:index, :show,:create, :update]
    before_action :set_other_spiritual_association, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :update]
  
    # GET /other_spiritual_associations
    def index
      @other_spiritual_associations = policy_scope(OtherSpiritualAssociation)
      render json: @other_spiritual_associations
    end
  
    # GET /other_spiritual_associations/1
    def show
      authorize @other_spiritual_association
      render json: @other_spiritual_association
    end
  
    # GET /other_spiritual_associations/new
    def new
      @other_spiritual_association = OtherSpiritualAssociation.new
    end
  
    # GET /other_spiritual_associations/1/edit
    def edit
    end
  
    # POST /other_spiritual_associations
    def create
      @other_spiritual_association = OtherSpiritualAssociation.new(other_spiritual_association_params)
      # authorize @other_spiritual_association
      if @other_spiritual_association.save
        render json: @other_spiritual_association
      else
        render json: @other_spiritual_association.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /other_spiritual_associations/1
    def update
      # authorize @other_spiritual_association
      if @other_spiritual_association.update(other_spiritual_association_params)
        render json: @other_spiritual_association
      else
        render json: @other_spiritual_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /other_spiritual_associations/1
    def destroy
      authorize @other_spiritual_association
      res = @other_spiritual_association.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_other_spiritual_association
        @other_spiritual_association = OtherSpiritualAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def other_spiritual_association_params
        params.require(:other_spiritual_association).permit(:organization_name, :association_description, :associated_since_year, :associated_since_month, :duration_of_practice, :sadhak_profile_id)
      end
  end
end
