module Api
  module Statistics
    class FlightQuery
      attr_reader :relation

      def initialize(relation: Flight.all)
        @relation = relation
      end

      def with_stats
        relation.joins(:bookings)
                .select('sum(bookings.seat_price * bookings.no_of_seats) as revenue')
                .select('sum(bookings.no_of_seats) as no_of_booked_seats')
                .select('flights.no_of_seats')
                .select('flights.*')
                .group('flights.id')
      end
    end
  end
end
