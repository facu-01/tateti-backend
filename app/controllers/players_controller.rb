class PlayersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  def index
    @players = Player.all
    render json: @players, status: :ok
  end

  def create
    player = Player.new(player_params)
    if player.save
      render json: { name: player.name, email: player.email }, status: :created
    else
      render json: { errors: player.errors }, status: :unprocessable_entity
    end
  end

  def show
    render json: { name: @current_player.name }, status: 200
  end

  private

  def player_params
    params.permit(:name, :email, :password)
  end

end
