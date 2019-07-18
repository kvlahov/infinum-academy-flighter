class CompanySerializer < ActiveModel::Serializer
  attribute :id
  attribute :name
  attribute :created_at, :updated_at
end
