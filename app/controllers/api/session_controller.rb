module Api
  class SessionController < ApplicationController
    def create
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        render json: session, status: :created
      else
        render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
      end
    end

    def destroy
      token = request.headers['Authorization']
      User.find_by(token: token)
          .regenerate_token
          .save
      head :no_content
    end
  end
end
