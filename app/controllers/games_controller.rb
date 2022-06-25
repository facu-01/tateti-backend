class GamesController < ApplicationController
  before_action :fetch_game, only: %i[join_game show move]
  before_action :check_player_in_game, only: %i[move show]
  before_action :check_game_ended, only: %i[move]

  def index
    games = Game.where(player1_id: @current_player.id).or(Game.where(player2_id: @current_player.id)).map { |g|
      { token: g.generate_token,
        status: g.status,
        versus: g.versus(@current_player)&.name,
        yourTurn: g.player_turn?(@current_player),
        winner: g.winner_player&.name,
      } }
    render json: games, status: :ok
  end

  def create
    game = Game.new
    game.initialize_game(@current_player)
    game_token = game.generate_token
    if game.save
      render json: { gameToken: game_token, gameStatus: game.status }, status: :ok
    else
      render json: { errors: game.errors }, status: :unprocessable_entity
    end
  end

  def join_game
    if @game.player_in_game?(@current_player)
      return render json: { errors: 'You cannot join the same game twice' }, status: :bad_request
    end
    return render json: { errors: 'Cannot join game, the game is complete' }, status: :forbidden if @game.complete?

    @game.join_game(@current_player)
    if @game.save
      render json: { message: 'Successfully joined!' }, status: :ok
    else
      render json: { errors: @game.errors }, status: :unprocessable_entity
    end
  end

  def show
    if @game.status_waiting_for_join?
      return render json: { message: 'Waiting for another player!', status: @game.status }, status: :ok
    end

    render json: {
      table: @game.table,
      yourTurn: @game.player_turn?(@current_player),
      yourSymbol: if @game.first_player_id
                    @current_player.id == @game.first_player_id ? 'x' : 'o'
                  end,
      status: @game.status,
      versus: @game.versus(@current_player)&.name,
      ended: @game.ended?,
      winner: @game.winner_player&.name,
      winningCombination: @game.winning_combination,
      youWin: @game.winner_player ? @game.winner_player.id == @current_player.id : nil
    }
  end

  def move
    cell_index = params.require(:cellIndex)
    # check if it is the turn of the player
    unless @game.player_turn?(@current_player)
      return render json: { errors: 'Its not your turn', table: @game.table }, status: :ok
    end

    new_move = @game.moves.new(cell_index:, player_id: @current_player.id, prev_move_id: @game.moves.last&.id)
    symbol = @current_player.id == @game.first_player_id ? 'x' : 'o'

    @game.table.map!.with_index { |c, i| i != cell_index.to_i ? c : symbol }

    if new_move.save
      if @game.player_win?(@current_player)
        @game.player_winner_id = @current_player.id
        @game.status_finished!
      end
      # check if is a tie
      @game.status_tied! if @game.a_tie?

      if @game.save
        render json: { table: @game.table, status: @game.status, finished: @game.ended? ? true : false }, status: :ok
      else
        render json: { errors: @game.errors }, status: :bad_request
      end
    else
      render json: { errors: new_move.errors }, status: :bad_request
    end
  end

  private

  def invalid_game_token
    render status: :bad_request, json: { errors: 'Invalid token' }
  end

  def fetch_game
    game_token = params.require(:gameToken)

    begin
      game_id = Game.read_token(game_token)
    rescue ArgumentError
      return render status: :bad_request, json: { errors: 'Invalid token' }
    end
    @game = Game.find(game_id)
  end

  def check_player_in_game
    unless @game.player_in_game?(@current_player)
      render json: { errors: 'This game is not for you!, did you try joining the game?' }, status: :forbidden
    end
  end

  def check_game_ended
    render json: { message: 'The game has finished!' }, status: :ok if @game.ended?
  end

end
