module Api::V1
  class FrequentSadhnaTypesController < BaseController
    before_action :set_frequent_sadhna_type, only: [:show, :edit, :update, :destroy]
  
    # GET /frequent_sadhna_types
    def index
      @frequent_sadhna_types = policy_scope(FrequentSadhnaType)
      render json: @frequent_sadhna_types
    end
  
    # GET /frequent_sadhna_types/1
    def show
      render json: @frequent_sadhna_type
    end
  
    # GET /frequent_sadhna_types/new
    def new
      @frequent_sadhna_type = FrequentSadhnaType.new
    end
  
    # GET /frequent_sadhna_types/1/edit
    def edit
    end
  
    # POST /frequent_sadhna_types
    def create
      @frequent_sadhna_type = FrequentSadhnaType.new(frequent_sadhna_type_params)
  
      respond_to do |format|
        if @frequent_sadhna_type.save
          format.html { redirect_to @frequent_sadhna_type, notice: 'Frequent sadhna type was successfully created.' }
          format.json { render :show, status: :created, location: @frequent_sadhna_type }
        else
          format.html { render :new }
          format.json { render json: @frequent_sadhna_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /frequent_sadhna_types/1
    def update
      respond_to do |format|
        if @frequent_sadhna_type.update(frequent_sadhna_type_params)
          format.html { redirect_to @frequent_sadhna_type, notice: 'Frequent sadhna type was successfully updated.' }
          format.json { render :show, status: :ok, location: @frequent_sadhna_type }
        else
          format.html { render :edit }
          format.json { render json: @frequent_sadhna_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /frequent_sadhna_types/1
    # DELETE /frequent_sadhna_types/1.json
    def destroy
      @fst = @frequent_sadhna_type.destroy
      respond_to do |format|
        format.html { redirect_to frequent_sadhna_types_url, notice: 'Frequent sadhna type was successfully destroyed.' }
        format.json { render json: @fst }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_frequent_sadhna_type
        @frequent_sadhna_type = FrequentSadhnaType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def frequent_sadhna_type_params
        params.require(:frequent_sadhna_type).permit(:name)
      end
  end
end
