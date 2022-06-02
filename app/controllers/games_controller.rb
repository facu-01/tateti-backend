class GamesController < ApplicationController
  before_action :fetch_game, only: [:join_game, :show, :move]
  before_action :fetch_player, only: [:create, :join_game, :show, :move]
  before_action :can_play, only: [:show, :move]

  def index
    @games = Game.all
    get_response(message: 'All games', data: @games)
  end

  def create
    initial_table = [[nil, nil, nil], [nil, nil, nil], [nil, nil, nil]]
    @game = Game.new(player1_id: @player.id, table: initial_table)
    if @game.save
      get_response(message: 'Game created successfully', data: { gameId: @game.id })
    else
      get_response(message: @game.errors, status: 400)
    end
  end

  def join_game
    if !@game.player2_id.nil?
      get_response(message: 'Cannot join game, the game is complete ', data: { joined: false })
    else
      @game.player2_id = @player.id
      if @game.save
        get_response(message: 'Successfully joined', data: { joined: true })
      else
        get_response(message: @game.errors, status: 400)
      end
    end
  end

  def show
    if @game.moves.empty?
      if @game.player1_id == @player.id
        get_response(message: 'Its your turn', data: { table: @game.table, yourTurn: true })
      else
        get_response(message: 'Its not your turn', data: { table: @game.table, yourTurn: false })
      end
    else
      if @game.moves.last.player.id == @player.id
        get_response(message: 'Its not your turn', data: { table: @game.table, yourTurn: false })
      end
      get_response(message: 'Its your turn', data: { table: @game.table, yourTurn: true })
    end
  end

  def move
    play = params.require(:play).permit(:row, :column)
    @game.moves.new(column: play[:column], row: play[:row], player_id: @player.id)
    if @game.save
      get_response(message: 'LOL', data: @game)
    else
      get_response(message: :'no LOL', data: @game.errors)
    end

  end

  private

  def fetch_game
    @game = Game.find(params.require(:gameId))
  end

  def fetch_player
    @player = Player.find(params.require(:playerId))
  end

  def can_play
    if @game.player1_id != @player.id && @game.player2_id != @player.id
      get_response(message: 'This game is not for you!, did you try joining the game?', status: 403)
    end
  end

end
