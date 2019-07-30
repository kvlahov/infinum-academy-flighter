module Api
  module Statistics
    class FlightSerializer < ActiveModel::Serializer
      attribute :id
      attribute :revenue
      attribute :no_of_booked_seats
      attribute :occupancy

      delegate :revenue, to: :this_flight
      delegate :no_of_booked_seats, to: :this_flight
      delegate :occupancy, to: :this_flight

      private

      def this_flight
        FlightQuery.new(relation: Flight.where(id: object.id))
      end
    end
  end
end
