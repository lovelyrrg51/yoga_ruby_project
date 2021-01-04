class RolePolicy
  attr_reader :user, :role

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope.all
      end
    end
  end
  
  def initialize(user, role)
    @user = user
    @role = role
  end

  def allowed?
    # Remember to db:populate and add the special Role object for "Super Admin".
    admin_role = Role.find_by_name("Super Admin")
    @user.roles.include?(admin_role)
  end

end