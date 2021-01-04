module Episode
  class DigitalAssetPolicy
    attr_reader :user, :digital_asset

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
    
    def initialize(user, digital_asset)
      @user = user
      @digital_asset = digital_asset
    end

    def index?
     user.present? && (user.super_admin? || user.club_admin?)
    end

    def edit?
     index?
    end

    def create?
      index?
    end
    
    def update?
      index?
    end
    
    def destroy?
      index?
    end
  end
end
