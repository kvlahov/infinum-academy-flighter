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
  belongs_to :user
  belongs_to :flight

  def flight_not_in_past?
    return if flight && flight.flys_at > DateTime.current

    errors.add(:flight, 'flights can\'t be in the past')
  end
end
