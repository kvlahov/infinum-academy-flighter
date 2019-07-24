class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include Pundit
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def record_not_found
    render json: { errors: 'Bad request! Record not found' }, status: :bad_request
  end

  def user_not_authorized
    render json: { errors: { resource: 'forbidden' } }, status: :forbidden
  end
end
