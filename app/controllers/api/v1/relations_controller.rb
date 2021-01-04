module Api::V1
  class RelationsController < BaseController
     respond_to :json
    before_action :authenticate_user!, :except => [:index]
    skip_before_action :verify_authenticity_token, :only => [:index]
  
     def index
        if params[:user_id]
  #          @sadhak_profile = Relations.find_by_user_id(params[:user_id])
          @relations = Relation.where(user_id: params[:user_id])
        end
        render json: @relations
      end
  
  	def show
  		@relation = current_user.relation
      render json: @relation
  	end
  
  	def update
      @relation = current_user.relation
  		@relation.update_attributes(relation_params)
      #Note we still need to implement the profile complete check.
  
     render json: @relation
  	end
  
  	def create
  		@relation = relation.create
      render json: @relation
    end
  
  	def edit
  		@relation = current_user.relation
  	end
  
  private
      def sadhak_profile_params
        params.require(:relation).permit! #(:SadhakProfile)
      end
  
  end
end
