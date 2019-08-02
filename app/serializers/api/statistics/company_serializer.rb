module Api
  module Statistics
    class CompanySerializer < ActiveModel::Serializer
      attribute :company_id do
        object.id
      end
      attribute :total_revenue
      attribute :total_no_of_booked_seats
      attribute :average_price_of_seats do
        if object.total_no_of_booked_seats != 0
          (object.total_revenue / object.total_no_of_booked_seats.to_f).round(1)
        else
          0
        end
      end
    end
  end
end
