class EventOrderLineItemPolicy < ApplicationPolicy
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
