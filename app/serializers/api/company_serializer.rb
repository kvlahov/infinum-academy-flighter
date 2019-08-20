module Api
  class CompanySerializer < ActiveModel::Serializer
    attribute :id
    attribute :name
    attributes :created_at, :updated_at
    attribute :no_of_active_flights

    def no_of_active_flights
      object.flights.active.size
    end
  end
end
