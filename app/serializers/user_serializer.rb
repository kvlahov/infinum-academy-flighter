class UserSerializer < ActiveModel::Serializer
  attribute :id
  attribute :first_name
  attribute :last_name
  attribute :email
  attribute :role
  attributes :created_at, :updated_at
end
