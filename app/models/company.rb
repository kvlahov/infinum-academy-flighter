# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Company < ApplicationRecord
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }

  has_many :flights, dependent: :destroy

  def self.filter_flights(filter)
    if filter == 'active'
      joins(:flights).merge(Flight.active).group(:id)
    else
      all
    end
  end

  def self.default_ordering
    'name'
  end

  def self.with_active_flights
    Company.left_joins(:flights)
           .select('companies.*')
           .select("count(flights.id) filter(where(flights.flys_at > '#{Time.current}'))
                   as no_of_active_flights")
           .group(:id)
  end
end
