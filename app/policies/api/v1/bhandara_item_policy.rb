class Api::V1::BhandaraItemPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :bhandara_item
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, bhandara_item)
    @user = user
    @bhandara_item = bhandara_item
  end
  
  def create?
    # if user has authorization to create bhandara_details
    BhandaraDetail.new(user, bhandara_item.bhandara_detail).create?
  end
  
  def update?
    # if user has authorization to update bhandara_details
    BhandaraDetail.update(user, bhandara_item.bhandara_detail).update?
    return
  end
  
  def destroy?
    # if user has authorization to destroy bhandara_details
    BhandaraDetail.new(user, bhandara_item.bhandara_detail).destroy?
  end
end
