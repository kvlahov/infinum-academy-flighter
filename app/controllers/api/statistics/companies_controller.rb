module Api
  module Statistics
    class CompaniesController < ApplicationController
      # GET api/statistics/flights
      def index
        authorize Company, policy_class: Api::Statistics::CompanyPolicy
        render json: CompanyQuery.new.with_stats,
               each_serializer: Api::Statistics::CompanySerializer
      end
    end
  end
end
