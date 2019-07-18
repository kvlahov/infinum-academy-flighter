class FlightSerializer < ActiveModel::Serializer
  attribute :id
  attribute :name
  attribute :no_of_seats
  attribute :base_price
  attribute :flys_at
  attribute :lands_at
  attributes :created_at, :updated_at

  belongs_to :company, serializer: CompanySerializer
end
