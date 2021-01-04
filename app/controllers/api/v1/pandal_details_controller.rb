module Api::V1
  class PandalDetailsController < BaseController
    before_action :authenticate_user!
    before_action :set_pandal_detail, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /pandal_details
    def index
  #     if params[:event][:id].present?
  #       event_id = params[:event][:id]
  #       if event_id.present?
  #         @pandal_details = PandalDetail.where(event_id: event_id)
  #         render json:  @pandal_details
  #       else
  #         render json:  []
  #       end
  #     else
        @pandal_deatails = policy_scope(PandalDetail)
        render json:  @pandal_deatails
  #     end
    end
  
    # GET /pandal_details/1
    def show
      render json: @pandal_detail
    end
  
    # GET /pandal_details/new
    def new
      @pandal_detail = PandalDetail.new
    end
  
    # GET /pandal_details/1/edit
    def edit
    end
  
    # POST /pandal_details
    def create
      @pandal_detail = PandalDetail.new(pandal_detail_params)
      authorize @pandal_detail
      if @pandal_detail.save
        render json: @pandal_detail
      else
        render json: @pandal_detail.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /pandal_details/1
    def update
      authorize @pandal_detail
      if @pandal_detail.update(pandal_detail_params)
        render json: @pandal_detail
      else
        render json: @pandal_detail.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /pandal_details/1
    def destroy
      authorize @pandal_detail
      pand = @pandal_detail.destroy
      render json: pand
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pandal_detail
        @pandal_detail = PandalDetail.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pandal_detail_params
        params.require(:pandal_detail).permit(:len, :width, :seating_type, :matresses_count, :chairs_count, :arrangement_details, :event_id)
      end
  end
end
