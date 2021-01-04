module Api::V1
  class UserTicketAssociationsController < BaseController
    before_action :set_user_ticket_association, only: [:show, :edit, :update, :destroy]
  
    # GET /user_ticket_associations
    # GET /user_ticket_associations.json
    def index
      @user_ticket_associations = UserTicketAssociation.all
    end
  
    # GET /user_ticket_associations/1
    # GET /user_ticket_associations/1.json
    def show
    end
  
    # GET /user_ticket_associations/new
    def new
      @user_ticket_association = UserTicketAssociation.new
    end
  
    # GET /user_ticket_associations/1/edit
    def edit
    end
  
    # POST /user_ticket_associations
    # POST /user_ticket_associations.json
    def create
      @user_ticket_association = UserTicketAssociation.new(user_ticket_association_params)
  
      respond_to do |format|
        if @user_ticket_association.save
          format.html { redirect_to @user_ticket_association, notice: 'User ticket association was successfully created.' }
          format.json { render :show, status: :created, location: @user_ticket_association }
        else
          format.html { render :new }
          format.json { render json: @user_ticket_association.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /user_ticket_associations/1
    # PATCH/PUT /user_ticket_associations/1.json
    def update
      respond_to do |format|
        if @user_ticket_association.update(user_ticket_association_params)
          format.html { redirect_to @user_ticket_association, notice: 'User ticket association was successfully updated.' }
          format.json { render :show, status: :ok, location: @user_ticket_association }
        else
          format.html { render :edit }
          format.json { render json: @user_ticket_association.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /user_ticket_associations/1
    # DELETE /user_ticket_associations/1.json
    def destroy
      @user_ticket_association.destroy
      respond_to do |format|
        format.html { redirect_to user_ticket_associations_url, notice: 'User ticket association was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user_ticket_association
        @user_ticket_association = UserTicketAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def user_ticket_association_params
        params.require(:user_ticket_association).permit(:ticket_id, :user_id)
      end
  end
end
