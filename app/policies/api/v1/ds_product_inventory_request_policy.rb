class Api::V1::DsProductInventoryRequestPolicy < Api::V1::ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
