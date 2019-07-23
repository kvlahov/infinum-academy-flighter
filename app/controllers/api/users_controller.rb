module Api
  class UsersController < ApplicationController
    # GET /api/users
    def index
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
      user = User.find(params[:id])
      render json: user
    end

    # PUT    /api/users/:id
    def update
      user = User.find(params[:id])
      if user.update(user_params)
        render json: user
      else
        render json: { errors: user.errors }, status: :bad_request
      end
    end

    # DELETE /api/users/:id
    def destroy
      User.find(params[:id]).destroy
      head :no_content
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end
  end
end
