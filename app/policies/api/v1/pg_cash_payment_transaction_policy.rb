class Api::V1::PgCashPaymentTransactionPolicy < Api::V1::ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
