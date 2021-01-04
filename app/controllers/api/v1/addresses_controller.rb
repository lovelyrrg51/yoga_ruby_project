module Api::V1
  class AddressesController < BaseController
    before_action :authenticate_user!, except: [:create, :index, :update]
    before_action :set_address, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:create, :index, :update]
    respond_to :json
  
    # GET /addresses
    def index
      @addresses = policy_scope(Address)
      render json: @addresses
    end
  
    # GET /addresses/1
    def show
      @addresses = Address.where(nil)
      @addresses = @addresses.addressable_type(params[:addressable_type]) if params[:addressable_type].present?
      render json: @address
    end
  
    # GET /addresses/new
    def new
      @address = Address.new
    end
  
    # GET /addresses/1/edit
    def edit
    end
  
    # POST /addresses
    def create
      @address = Address.new(address_params)
      authorize @address
      if @address.save
        render json: @address
      else
        render json: @address.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /addresses/1
    def update
      authorize @address
      if @address.update(address_params)
        render json: @address
      else
        render json: @address.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /addresses/1
    def destroy
      authorize @address
      address = @address.destroy
      render json: address
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_address
        @address = Address.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def address_params
        params.require(:address).permit(:first_line, :second_line, :city_id, :state_id, :country_id, :postal_code, :addressable_id, :addressable_type, :lat, :lng, :sadhak_profile_id, :other_state, :other_city)
      end
  end
end
