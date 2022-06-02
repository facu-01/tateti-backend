class PlayersController < ApplicationController

  def index
    @players = Player.all
    get_response(message: 'All players', data: @players)
  end

  def create
    name = params.require(:name)
    @player = Player.new(name:)
    if @player.save
      get_response(message: 'Player created successfully', data: @player)
    else
      get_response(message: @player.errors, status: 400)
    end
  end

end
