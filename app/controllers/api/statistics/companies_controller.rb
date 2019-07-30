module Api
  module Statistics
    class CompaniesController < ApplicationController
      # GET api/statistics/flights
      def index
        authorize Company, policy_class: CompanyPolicy
        render json: Company.all
      end
    end
  end
end
