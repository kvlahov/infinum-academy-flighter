module Api
  class BookingsController < ApplicationController
    before_action :authenticate

    # GET /api/bookings
    def index
      bookings = policy_scope(Booking)

      render json: bookings
    end

    # POST   /api/bookings
    def create
      booking = Booking.new(booking_params)
      booking.user = pundit_user

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
