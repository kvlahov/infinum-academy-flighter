module Api
  class BookingsController < ApplicationController
    # GET /api/bookings
    def index
      render json: Booking.all
    end

    # POST   /api/bookings
    def create
      booking = Booking.new(booking_params)
      if booking.save
        render json: booking, status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    # GET    /api/bookings/:id
    def show
      booking = Booking.find(params[:id])
      render json: booking
    end

    # PUT    /api/bookings/:id
    def update
      booking = Booking.find(params[:id])
      if booking.update(booking_params)
        render json: booking
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    # DELETE /api/bookings/:id
    def destroy
      Booking.find(params[:id]).destroy
      head :no_content
    end

    private

    def booking_params
      params.require(:booking).permit(
        :no_of_seats, :seat_price,
        :user_id,
        :flight_id
      )
    end
  end
end