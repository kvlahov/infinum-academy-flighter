class BookingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        user.bookings
      end
    end
  end

  def index?
    true
  end

  def create?
    true
  end

  def show?
    user.admin? || record.user == user
  end

  def update?
    user.admin? || record.user == user
  end

  def destroy?
    user.admin? || record.user == user
  end

  def permitted_attributes
    if user.admin?
      [:no_of_seats, :seat_price, :user_id, :flight_id]
    else
      [:no_of_seats, :seat_price, :flight_id]
    end
  end
end
