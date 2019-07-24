module Api
  class UsersController < ApplicationController
    before_action :authenticate, except: :create

    # GET /api/users
    def index
      authorize user
      render json: User.all
    end

    # POST   /api/users
    def create
      user = User.new(user_params)
      if user.save
        render json: user, status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    # GET    /api/users/:id
    def show
      policy_scope(User)

      user = User.find(params[:id])
      render json: user
    end

    # PUT    /api/users/:id
    def update
      policy_scope(User)

      user = User.find(params[:id])
      if user.update(user_params)
        render json: user
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    # DELETE /api/users/:id
    def destroy
      policy_scope(User)

      User.find(params[:id]).destroy
      head :no_content
    end

    private

    def user_params
      params.require(:user).permit(policy(user).permitted_attributes)
    end

    def authenticate
      auth_token = request.headers['Authorization']
      return unless User.find_by(token: auth_token).nil?

      render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
    end
  end
end
