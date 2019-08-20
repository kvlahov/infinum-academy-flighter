module Api
  module Statistics
    class FlightSerializer < ActiveModel::Serializer
      attribute :flight_id do
        object.id
      end
      attribute :revenue
      attribute :no_of_booked_seats
      attribute :occupancy do
        ratio = (object.no_of_booked_seats.to_f / object.no_of_seats).round(2)
        "#{ratio * 100}%"
      end
    end
  end
end
