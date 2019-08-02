module Api
  module Statistics
    class CompanyQuery
      attr_reader :relation

      def initialize(relation: Company.all)
        @relation = relation
      end

      def with_stats
        relation.left_joins(flights: [:bookings])
                .select('companies.*')
                .select('coalesce(sum(bookings.seat_price * bookings.no_of_seats), 0)
                         as total_revenue')
                .select('coalesce(sum(bookings.no_of_seats), 0) as total_no_of_booked_seats')
                .select('coalesce(round(avg(bookings.seat_price), 1), 0) as average_price_of_seats')
                .group('companies.id')
      end
    end
  end
end
