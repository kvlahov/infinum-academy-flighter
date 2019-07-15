# == Schema Information
#
# Table name: flights
#
#  id          :bigint           not null, primary key
#  name        :string
#  no_of_seats :integer
#  base_price  :integer
#  flys_at     :datetime
#  lands_at    :datetime
#  company_id  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Flight < ApplicationRecord
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false, scope: :company_id }
  validates :flys_at, :lands_at, presence: true
  validates :flys_at_before_lands_at?
  validates :base_price, presence: true,
                         numericality: { greater_than: 0 }

  belongs_to :company

  has_many :bookings, dependent: :destroy
  has_many :users, through: :bookings

  def flys_at_before_lands_at?
    return if flys_at < lands_at

    errors.add(:flys_at, 'must be before ' + :lands_at.to_s)
  end
end
