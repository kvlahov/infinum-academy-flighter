module Api
  class SessionController < ApplicationController
    skip_before_action :authenticate, only: :create

    def create
      authorize Session
      user = User.find_by(email: params[:session][:email])
      if user&.authenticate(params[:session][:password])
        render json: { session: {
          token: user.token, user: UserSerializer.new(user)
        } }, status: :created
      else
        render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
      end
    end

    def destroy
      authorize Session
      user = User.find_by(token: request.headers['Authorization'])
      user.regenerate_token
      user.save
      head :no_content
    end
  end
end
