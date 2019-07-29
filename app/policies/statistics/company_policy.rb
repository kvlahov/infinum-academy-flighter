module Statistics
  class CompanyPolicy < ApplicationPolicy
    def index
      user.admin?
    end
  end
end
