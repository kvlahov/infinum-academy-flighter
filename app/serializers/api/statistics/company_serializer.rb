module Api
  module Statistics
    class CompanySerializer < ActiveModel::Serializer
      attribute :id
      attribute :total_revenue
      attribute :total_no_of_booked_seats
      attribute :average_price_of_seats

      delegate :total_revenue, to: :this_company
      delegate :total_no_of_booked_seats, to: :this_company
      delegate :average_price_of_seats, to: :this_company

      private

      def this_company
        CompanyQuery.new(relation: Company.where(id: object.id))
      end
    end
  end
end
