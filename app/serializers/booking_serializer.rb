class BookingSerializer < ActiveModel::Serializer
  attribute :id
  attribute :no_of_seats
  attribute :seat_price
  attributes :created_at, :updated_at
  attribute :total_price

  belongs_to :flight
  belongs_to :user

  def total_price
    object.no_of_seats * object.seat_price.round
  end
end
