class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def record_not_found
    render json: { error: 'Bad request! Record not found' }, status: :bad_request
  end
end
