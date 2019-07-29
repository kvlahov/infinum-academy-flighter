module Statistics
  class FlightPolicy < ApplicationPolicy
    def index
      user.admin?
    end
  end
end
