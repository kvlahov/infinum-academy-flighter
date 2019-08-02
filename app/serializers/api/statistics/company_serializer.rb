module Api
  module Statistics
    class CompanySerializer < ActiveModel::Serializer
      attribute :company_id do
        object.id
      end
      attribute :total_revenue
      attribute :total_no_of_booked_seats
      attribute :average_price_of_seats do
        object.average_price_of_seats.to_f
      end
    end
  end
end
