module Api::V1
  class SubSourceTypesController < BaseController
    before_action :authenticate_user!, except: [:index]
    before_action :set_sub_source_type, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:index]
    respond_to :json
  
    # GET /sub_source_types
    def index
      render json: @sub_source_types
    end
  
    # GET /sub_source_types/1
    def show
      authorize @sub_source_type
      render json: @sub_source_type
    end
  
    # GET /sub_source_types/new
    def new
      @sub_source_type = SubSourceType.new
    end
  
    # GET /sub_source_types/1/edit
    def edit
    end
  
    # POST /sub_source_types
    def create
      @sub_source_type = SubSourceType.new(sub_source_type_params)
      authorize @sub_source_type
      if @sub_source_type.save
        render json: @sub_source_type
      else
        render json: @sub_source_type.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sub_source_types/1
    def update
      authorize @sub_source_type
      if @sub_source_type.update(sub_source_type_params)
        render json: @sub_source_type
      else
        render json: @sub_source_type.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /sub_source_types/1
    def destroy
      authorize @sub_source_type
      if @sub_source_type.update(is_deleted: true)
        render json: @sub_source_type
      else
        render json: @sub_source_type.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    def locate_collection
      @sub_source_types = SubSourceTypePolicy::Scope.new(current_user, SubSourceType).resolve(filtering_params)
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sub_source_type
        @sub_source_type = SubSourceType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sub_source_type_params
        params.require(:sub_source_type).permit(:source_info_type_id, :sub_source_name)
      end
  
      def filtering_params
        params.slice(:source_info_type_id)
      end
  end
end
