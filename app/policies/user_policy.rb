class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(token: user.token)
      end
    end
  end

  def show?
    user.admin? || record == user
  end

  def update?
    user.admin? || record.token == user.token
  end

  def destroy?
    user.admin? || record.token == user.token
  end

  def permitted_attributes
    if user.admin?
      [:first_name, :last_name, :email, :password, :role]
    else
      [:first_name, :last_name, :email, :password]
    end
  end
end
