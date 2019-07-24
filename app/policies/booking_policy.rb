class BookingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: { token: user.token })
      end
    end
  end

  def permitted_attributes
    if user.admin?
      [:no_of_seats, :seat_price, :user_id, :flight_id]
    else
      [:no_of_seats, :seat_price, :flight_id]
    end
  end
end
