# frozen_string_literal: true

class GamesController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]
  before_action :fetch_game, only: %i[join_game show move]
  before_action :can_play, only: %i[show move]
  before_action :check_game_ended, only: %i[move show]

  def index
    @games = Game.all
    render json: @games, status: :ok
  end

  def create
    game = Game.new
    game.initialize_game(@current_player)
    if game.save
      render json: { table: game.table, status: game.status }, status: :ok
    else
      render json: { errors: game.errors }, status: :unprocessable_entity
    end
  end

  def join_game
    return render json: { errors: 'Cannot join game, the game is complete' }, status: :forbidden if @game.complete?

    return render json: { errors: 'You cannot join the same game twice' }, status: :bad_request if @game.player_in_game?(@current_player)

    @game.join_game(@current_player.id)
    if @game.save
      render json: { message: 'Successfully joined!' }, status: :ok
    else
      render json: { errors: @game.errors }, status: :unprocessable_entity
    end
  end

  def show
    render json: { message: 'Waiting for another player!' }, status: :ok if @game.status_waiting_for_join
    render json: { errors: 'This game is not for you!, did you try joining the game?' }, status: :forbidden unless @game.player_in_game?(@current_player)
    render json: { table: @game.table, yourTurn: @game.player_turn?(@current_player) }
  end

  def move
    cell_index = params.require(:cellIndex)
    # check if it is the turn of the player
    return render json: { errors: 'Its not your turn', table: @game.table }, status: :bad_request unless check_turn

    # return render json: { errors: 'Invalid move, that cell has already been occupied' } if @game.moves.all.map(&:cell_index).include? cell_index
    new_move = @game.moves.new(cell_index:, player_id: @current_player.id, prev_move_id: @game.moves.last&.id)
    symbol = @current_player.id == @game.first_player_id ? 'x' : 'o'

    @game.table.map!.with_index { |c, i| i != cell_index ? c : symbol }

    if new_move.save
      # check if player wins
      winning_combinations = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]

      player_cells = @game.moves.all.where(player_id: @current_player.id).map(&:cell_index)

      winner = winning_combinations.any? { |combination| combination.all? { |c| player_cells.include?(c) } }

      if winner
        @game.player_winner_id = @current_player.id
        @game.status_finished!
      end
      # check if is a tie
      a_tie = @game.table.none?(&:nil?)
      @game.status_tied! if a_tie

      if @game.save
        render json: { table: @game.table, status: @game.status }, status: :ok
      else
        render json: { errors: @game.errors }, status: :bad_request
      end
    else
      render json: { errors: @game.errors }, status: :bad_request
    end
  end

  private

  def fetch_game
    @game = Game.find(params.require(:gameId))
  end

  def check_game_ended
    if @game.status_finished? || @game.status_tied?
      render json: { table: @game.table, status: @game.status, winner: @game.status_finished? ? Player.find_by_id(@game.player_winner_id).name : nil }, status: :ok
    end
  end

end
