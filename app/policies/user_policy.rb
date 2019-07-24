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

  def index?
    user.admin?
  end

  def permitted_attributes
    if user.admin?
      [:first_name, :last_name, :email, :password, :role]
    else
      [:first_name, :last_name, :email, :password]
    end
  end
end
