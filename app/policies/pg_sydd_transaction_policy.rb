class PgSyddTransactionPolicy < ApplicationPolicy
  attr_reader :user, :pg_sydd_transaction
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
end
