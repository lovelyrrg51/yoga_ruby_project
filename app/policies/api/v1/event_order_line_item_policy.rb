class Api::V1::EventOrderLineItemPolicy < Api::V1::ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
     def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
end
