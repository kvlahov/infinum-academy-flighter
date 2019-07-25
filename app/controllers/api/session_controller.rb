module Api
  class SessionController < ApplicationController
    before_action :authenticate, only: :destroy

    def create
      user = User.find_by(email: params[:session][:email])
      if user&.authenticate(params[:session][:password])
        render json: { session: { token: user.token, user: user } }, status: :created
      else
        render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
      end
    end

    def destroy
      token = request.headers['Authorization']
      user = User.find_by(token: token)
      user.regenerate_token
      user.save
      head :no_content
    end
  end
end
