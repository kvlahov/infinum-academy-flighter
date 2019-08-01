class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include Pundit
  after_action :verify_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :authenticate

  def current_user
    User.find_by(token: request.headers['Authorization'])
  end

  def pundit_user
    current_user
  end

  def authenticate
    #    auth_token = request.headers['Authorization']
    #    return unless User.find_by(token: auth_token).nil?
    return unless current_user.nil?

    user_not_authenticated
  end

  private

  def record_not_found
    render json: { errors: 'Bad request! Record not found' }, status: :bad_request
  end

  def user_not_authorized
    render json: { errors: { resource: ['is forbidden'] } }, status: :forbidden
  end

  def user_not_authenticated
    render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
  end
end
