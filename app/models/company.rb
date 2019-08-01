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
      joins(:flights).where(flights: Flight.active).group(:id)
    else
      all
    end
  end

  def self.default_ordering
    'name'
  end
end
