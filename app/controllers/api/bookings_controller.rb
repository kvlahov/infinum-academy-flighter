module Api
  class BookingsController < ApplicationController
    before_action :authenticate

    # GET /api/bookings
    def index
      policy_scope(Booking)

      render json: Booking.all
    end

    # POST   /api/bookings
    def create
      booking = Booking.new(booking_params)
      booking.user = current_user

      if booking.save
        render json: booking, status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    # GET    /api/bookings/:id
    def show
      policy_scope(Booking)

      booking = Booking.find(params[:id])
      render json: booking
    end

    # PUT    /api/bookings/:id
    def update
      policy_scope(Booking)

      booking = Booking.find(params[:id])
      if booking.update(booking_params)
        render json: booking
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    # DELETE /api/bookings/:id
    def destroy
      policy_scope(Booking)

      Booking.find(params[:id]).destroy
      head :no_content
    end

    private

    def booking_params
      params.require(:booking).permit(policy(booking).permitted_attributes)
    end

    def authenticate
      auth_token = request.headers['Authorization']
      return unless User.find_by(token: auth_token).nil?

      render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
    end
  end
end
