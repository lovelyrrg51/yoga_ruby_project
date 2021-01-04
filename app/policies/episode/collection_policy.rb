module Episode
  class CollectionPolicy < ApplicationPolicy
  	attr_reader :user, :collection
  	class Scope < Struct.new(:user, :scope)
  		def resolve(filtering_params = nil)
        filtering_params.select!{|k,v| v.present?}
        if( filtering_params.present? )
          scope.filter(filtering_params)
        else
          scope.all
        end
      end
  	end

    def initialize(user, collection)
      @user = user
      @collection = collection
    end

    def create?
      user.super_admin?
    end

    def index?
    	user.super_admin?
    end

    def edit?
    	user.super_admin?
    end

    def update?
    	user.super_admin?
    end

    def destroy?
    	user.super_admin?
    end
  end
end