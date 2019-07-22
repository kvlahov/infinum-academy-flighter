class FlightSerializer < ActiveModel::Serializer
  attribute :token
  attribute :user, serialzer: UserSerializer
end
