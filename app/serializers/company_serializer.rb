class CompanySerializer < ActiveModel::Serializer
  attribute :id
  attribute :name
  attributes :created_at, :updated_at
  attribute :no_of_active_flights

  def no_of_active_flights
    Company.select('count(*)')
           .filter_flights('active')
           .where('companies.id = ?', object.id)
           .group(:id)
           .first
           .count
  end
end
