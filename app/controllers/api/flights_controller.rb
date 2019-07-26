module Api
  class FlightsController < ApplicationController
    skip_before_action :authenticate, only: [:index, :show]

    # GET /api/flights
    def index
      authorize Flight
      render json: Flight.includes(:company)
                         .active
                         .sorted
    end

    # POST   /api/flights
    def create
      authorize Flight
      flight = Flight.new(flight_params)

      if flight.save
        render json: flight, status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    # GET    /api/flights/:id
    def show
      flight = Flight.find(params[:id])
      authorize flight

      render json: flight
    end

    # PUT    /api/flights/:id
    def update
      flight = Flight.find(params[:id])
      authorize flight

      if flight.update(flight_params)
        render json: flight
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    # DELETE /api/flights/:id
    def destroy
      flight = Flight.find(params[:id])
      authorize flight

      flight.destroy
      head :no_content
    end

    private

    def flight_params
      params
        .require(:flight)
        .permit(:name, :no_of_seats, :base_price, :flys_at, :lands_at, :company_id)
    end
  end
end
