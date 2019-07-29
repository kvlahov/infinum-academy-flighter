module Statistics
  class FlightQuery
    attr_reader :relation

    def initialize(relation: Flight.all)
      @relation = relation
    end

    def revenue
      relation.bookings
              .sum(:total_price)
    end
  end
end
