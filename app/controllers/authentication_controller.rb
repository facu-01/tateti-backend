class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def login
    @player = Player.find_by_email(params[:email])
    if @player&.authenticate(params[:password])
      token = jwt_encode(player_id: @player.id)
      render json: { token: }, status: :ok
    else
      render json: { errors: 'unauthorized' }, status: :unauthorized
    end
  end

end
