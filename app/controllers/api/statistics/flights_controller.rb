module Api
  module Statistics
    class FlightsController < ApplicationController
      # GET api/statistics/flights
      def index
        authorize Flight, policy_class: Api::Statistics::FlightPolicy
        render json: FlightQuery.new.with_stats, each_serializer: Api::Statistics::FlightSerializer
      end
    end
  end
end
