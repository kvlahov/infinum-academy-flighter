class UserSerializer < ActiveModel::Serializer
  attrbute :id
  attribute :first_name
  attribute :last_name
  attrbute :email
  attribute :bookings, :flights
  attribute :created_at, :updated_at
end
