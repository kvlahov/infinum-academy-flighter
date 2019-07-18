class BookingSerializer < ActiveModel::Serializer
  attribute :id
  atrribute :no_of_seats
  atrribute :seat_price
  attribute :created_at, :updated_at

  belongs_to :flight, serializer: FlightSerializer
  belongs_to :user, serializer: UserSerializer
end
