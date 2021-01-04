module Api::V1
  class SourceInfoTypesController < BaseController
    before_action :authenticate_user!, except: [:index]
    before_action :set_source_info_type, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:index]
    respond_to :json
  
    # GET /source_info_types
    def index
      render json: @source_info_types
    end
  
    # GET /source_info_types/1
    def show
      authorize @source_info_type
      render json: @source_info_type
    end
  
    # GET /source_info_types/new
    def new
      @source_info_type = SourceInfoType.new
    end
  
    # GET /source_info_types/1/edit
    def edit
      render json: @source_info_type
    end
  
    # POST /source_info_types
    def create
      @source_info_type = SourceInfoType.new(source_info_type_params)
      authorize @source_info_type
      if @source_info_type.save
        render json: @source_info_type
      else
        render json: @source_info_type.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /source_info_types/1
    def update
      authorize @source_info_type
      if @source_info_type.update(source_info_type_params)
        render json: @source_info_type
      else
        render json: @source_info_type.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /source_info_types/1
    def destroy
      authorize @source_info_type
      if @source_info_type.update(is_deleted: true)
        render json: @source_info_type
      else
        render json: @source_info_type.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    def locate_collection
      @source_info_types = SourceInfoTypePolicy::Scope.new(current_user, SourceInfoType).resolve(filtering_params)
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_source_info_type
        @source_info_type = SourceInfoType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def source_info_type_params
        params.require(:source_info_type).permit(:source_name)
      end
  
      def filtering_params
        params.slice()
      end
  end
end
