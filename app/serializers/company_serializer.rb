class CompanySerializer < ActiveModel::Serializer
  attribute :id
  attribute :name
  attributes :created_at, :updated_at
end
