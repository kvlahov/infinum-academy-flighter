module Api
  class BookingsController < ApplicationController
    # GET /api/bookings
    def index
      authorize Booking
      bookings = policy_scope(Booking).includes(flight: [:company])
                                      .sorted(params['sort'])
                                      .filter_flights(params[:filter])
      render json: bookings
    end

    # POST   /api/bookings
    def create
      authorize Booking
      booking = Booking.new(booking_params)
      booking.user ||= current_user
      booking.seat_price = booking&.flight&.current_price

      if booking.save
        render json: booking, status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    # GET    /api/bookings/:id
    def show
      booking = Booking.find(params[:id])
      authorize booking

      render json: booking
    end

    # PUT    /api/bookings/:id
    def update
      booking = Booking.find(params[:id])
      authorize booking

      if booking.update(booking_params)
        booking.seat_price = booking&.flight&.current_price

        render json: booking
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    # DELETE /api/bookings/:id
    def destroy
      booking = Booking.find(params[:id])
      authorize booking

      booking.destroy
      head :no_content
    end

    private

    def booking_params
      params.require(:booking).permit(policy(Booking).permitted_attributes)
    end
  end
end
