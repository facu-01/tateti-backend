class ApplicationController < ActionController::API
  include JsonWebToken

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_request

  private

  def record_not_found(error)
    render status: :not_found, json: { message: error.message }
  end

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      decoded = jwt_decode(header)
      @current_player = Player.find(decoded[:player_id])

    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end

  end

end
