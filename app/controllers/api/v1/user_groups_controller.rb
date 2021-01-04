module Api::V1
  class UserGroupsController < BaseController
    before_action :authenticate_user!
    respond_to :json
  
    def index
      if UserGroupPolicy.new(current_user).index?
        @user_groups = UserGroup.all
        render json: @user_groups
      elsif !current_user.nil?
        @user_groups = current_user.user_groups
        render json: @user_groups
      else
        render json: {error: "Unauthorized access", status: 401}, status: 401
      end
    end
  
    def show
      @user_group = UserGroup.find(params[:id])
      if UserGroupPolicy.new(current_user, @user_group).show?
        render json: @user_group
      else
        render json: {error: "Unauthorized access", status: 401}, status: 401
      end
    end
  
    def new
      @user_group = UserGroup.new
    end
  
    def edit
      @user_group = UserGroup.find(params[:id])
      @user_group.update(user_group_parms)
    end
  
    def create
      if !UserGroupPolicy.new(current_user).create?
        render json: {error: "Unauthorized access", status: 401}, status: 401
        return false
      end
      @user_group = UserGroup.new(user_group_params)
  
      if @user_group.save
        render json: @user_group
      else
        render json: @user_group.errors, status: :unprocessable_entity
      end
    end
  
    def update
      @user_group = UserGroup.find(params[:id])
      if !UserGroupPolicy.new(current_user, @user_group).update?
        render json: {error: "Unauthorized access", status: 401}, status: 401
        return false
      end
      if @user_group.update(user_group_params)
        render json: @user_group
      else
        render json: @user_group.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /user_groups/1
    # DELETE /user_groups/1.json
    def destroy
      @user_group = UserGroup.find(params[:id])
      if !UserGroupPolicy.new(current_user, @user_group).destroy?
        render json: {error: "Unauthorized access", status: 401}, status: 401
        return false
      end
      @user_group.destroy
      render json: {}
  
    end
  
    private
  
      # Never trust parameters from the scary internet, only allow the white list through.
    def user_group_params
      params.require(:user_group).permit!
    end
  
  end
end
