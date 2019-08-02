# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  no_of_seats :integer
#  seat_price  :integer
#  user_id     :bigint
#  flight_id   :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Booking < ApplicationRecord
  validates :no_of_seats, :seat_price, presence: true,
                                       numericality: { greater_than: 0 }
  validate :flight_not_in_past?
  validate :enough_seats?
  belongs_to :user
  belongs_to :flight

  def flight_not_in_past?
    return if flight&.flys_at&.future?

    errors.add(:flight, 'flights can\'t be in the past')
  end

  def enough_seats?
    return if flight && no_of_seats && no_booked_seats + no_of_seats.to_i <= flight&.no_of_seats

    errors.add(:no_of_seats, 'not enough seats available')
  end

  def self.filter_flights(filter)
    if filter == 'active'
      joins(:flight).merge(Flight.active).group(:id)
    else
      all
    end
  end

  def total_price
    no_of_seats * seat_price.round
  end

  private

  def no_booked_seats
    Booking.joins(:flight).where(flight_id: flight.id).where.not(id: id).sum(:no_of_seats)
  end
end
