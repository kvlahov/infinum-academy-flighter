module Api
  module Statistics
    class FlightQuery
      attr_reader :relation

      def initialize(relation: Flight.all)
        @relation = relation
      end

      def revenue
        relation.joins(:bookings)
                .sum('bookings.seat_price * bookings.no_of_seats')
      end

      def no_of_booked_seats
        relation.joins(:bookings)
                .sum('bookings.no_of_seats')
      end

      def occupancy
        ratio = (no_of_booked_seats.to_f / relation.first.no_of_seats).round(2)
        "#{ratio * 100}%"
      end
    end
  end
end
