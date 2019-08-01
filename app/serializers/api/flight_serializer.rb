module Api
  class FlightSerializer < ActiveModel::Serializer
    attribute :id
    attribute :name
    attribute :no_of_seats
    attribute :base_price
    attribute :flys_at
    attribute :lands_at
    attributes :created_at, :updated_at
    attribute :no_of_booked_seats
    attribute :company_name
    attribute :current_price

    # belongs_to :company

    def no_of_booked_seats
      Booking.where(flight_id: object.id)
             .sum(:no_of_seats)
    end

    def company_name
      object.company.name
    end
  end
end
