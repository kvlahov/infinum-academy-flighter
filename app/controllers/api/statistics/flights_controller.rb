module Api
  module Statistics
    class FlightsController < ApplicationController
      # GET api/statistics/flights
      def index
        authorize Flight, policy_class: FlightPolicy
        render json: Flight.all
      end
    end
  end
end
