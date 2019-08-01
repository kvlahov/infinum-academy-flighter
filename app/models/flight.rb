# == Schemarequire 'json' Information
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
  validates :base_price, :no_of_seats, presence: true,
                                       numericality: { greater_than: 0 }
  validate :flys_at_before_lands_at?
  validate :overlapping?

  belongs_to :company

  has_many :bookings, dependent: :destroy
  has_many :users, through: :bookings

  scope :active, -> { where('flights.flys_at > ?', Time.current) }
  scope :name_cont, ->(name) { where('name ILIKE ?', "%#{name}%") }

  def flys_at_before_lands_at?
    return if flys_at && lands_at && flys_at < lands_at

    errors.add(:flys_at, 'must be before landing time')
  end

  def overlapping?
    return if company&.valid? &&
              flights_for_company
              .reject { |flight| flight.id == id }
              .map do |flight|
                (flight.flys_at..flight.lands_at).overlaps?(flys_at..lands_at)
              end
              .none?

    add_overlap_errors
  end

  def current_price
    date_booked = Time.current
    if (date_booked - flys_at) >= 15.days
      base_price
    else
      calculate_price(date_booked, 15).round
    end
  end

  def self.flys_at_eq(datetime)
    if datetime
      where("date_trunc('minute',flys_at) = ?", datetime.to_datetime.change(sec: 0))
    else
      all
    end
  end

  def self.no_of_available_seats_gteq(value)
    if value
      left_joins(:bookings)
        .group(:id)
        .having('flights.no_of_seats - coalesce(sum(bookings.no_of_seats), 0) >= ?', value)
    else
      all
    end
  end

  def self.cond_filter(params)
    relation = all
    relation = relation.name_cont(params[:name_cont]) if params[:name_cont]
    relation = relation.flys_at_eq(params[:flys_at_eq]) if params[:flys_at_eq]
    if params[:no_of_available_seats_gteq]
      relation.no_of_available_seats_gteq(params[:no_of_available_seats_gteq])
    else
      relation
    end
  end

  def self.filter(params)
    relation = all
    params.select { |key, _v| key.in? available_filters }.each do |key, value|
      relation = relation.method(key.to_s).call(value) if relation.respond_to?(key.to_s) && value
    end
    relation
  end

  def self.available_filters
    ['name_cont', 'flys_at_eq', 'no_of_available_seats_gteq']
  end

  private_class_method :available_filters

  private

  def calculate_price(date_booked, days_before)
    diff_in_days = (flys_at.to_date - date_booked.to_date).to_i
    diff_in_days = 0 if diff_in_days.negative?
    ((days_before - diff_in_days) / days_before.to_f + 1) * base_price
  end

  def flights_for_company
    Company.find(company_id).flights
  end

  def add_overlap_errors
    msg = 'flight schedule is overlapping with another flight'
    errors.add(:flys_at, msg)
    errors.add(:lands_at, msg)
  end
end
