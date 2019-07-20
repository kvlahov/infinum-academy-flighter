module Api
  class FlightsController < ApplicationController
    # GET /api/flights
    def index
      render json: Flight.all
    end

    # POST   /api/flights
    def create
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
      render json: flight
    end

    # PUT    /api/flights/:id
    def update
      flight = Flight.find(params[:id])
      if flight.update(flight_params)
        render json: flight
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    # DELETE /api/flights/:id
    def destroy
      Flight.find(params[:id]).destroy
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
