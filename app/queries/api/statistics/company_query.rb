module Api
  module Statistics
    class CompanyQuery
      attr_reader :relation

      def initialize(relation: Company.all)
        @relation = relation
      end

      def total_revenue
        relation.joins(flights: [:bookings]).sum('bookings.seat_price * bookings.no_of_seats')
      end

      def total_no_of_booked_seats
        relation.joins(flights: [:bookings]).sum('bookings.no_of_seats')
      end

      def average_price_of_seats
        relation.joins(:flights).average('flights.base_price').to_f.round(2)
      end
    end
  end
end
