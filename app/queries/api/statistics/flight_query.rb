module Api
  module Statistics
    class FlightQuery
      attr_reader :relation

      def initialize(relation: Flight.all)
        @relation = relation
      end

      def with_stats
        relation.left_joins(:bookings)
                .select('coalesce(sum(bookings.seat_price * bookings.no_of_seats), 0) as revenue')
                .select('coalesce(sum(bookings.no_of_seats), 0) as no_of_booked_seats')
                .select('flights.*')
                .group('flights.id')
      end
    end
  end
end
