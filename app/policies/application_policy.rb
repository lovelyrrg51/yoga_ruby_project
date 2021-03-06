class ApplicationPolicy
  attr_reader :user, :record, :permissions, :india_admin, :rc, :current_sadhak_profile

  def initialize(user, record)
    @user = user
    @record = record
    @permissions = user.try(:permissions, record) || {}
    @india_admin = @permissions[:india_admin] && record.try(:address).try(:country_id) == 113
    @rc = user.try(:rc?, record)
    @current_sadhak_profile = @user.try(:sadhak_profile)
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end
end

