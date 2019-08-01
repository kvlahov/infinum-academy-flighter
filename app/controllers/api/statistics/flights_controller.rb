module Api
  module Statistics
    class FlightsController < ApplicationController
      # GET api/statistics/flights
      def index
        authorize Flight, policy_class: Api::Statistics::FlightPolicy
        render json: Flight.all
      end
    end
  end
end
