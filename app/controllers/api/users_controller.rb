module Api
  class UsersController < ApplicationController
    skip_before_action :authenticate, only: :create

    # GET /api/users
    def index
      authorize User
      users = User.all

      render json: users.sorted(params['sort']).filter(params[:query])
    end

    # POST   /api/users
    def create
      authorize User
      user = User.new(user_params)
      if user.save
        render json: user, status: :created
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    # GET    /api/users/:id
    def show
      user = User.find(params[:id])
      authorize user

      render json: user
    end

    # PUT    /api/users/:id
    def update
      user = User.find(params[:id])
      authorize user

      if user.update(user_params)
        render json: user
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    # DELETE /api/users/:id
    def destroy
      user = User.find(params[:id])
      authorize user

      user.destroy
      head :no_content
    end

    private

    def user_params
      params.require(:user).permit(policy(User).permitted_attributes)
    end
  end
end
