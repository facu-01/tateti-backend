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
    initial_table = [nil, nil, nil, nil, nil, nil, nil, nil, nil]
    @game = Game.new(player1_id: @current_player.id, table: initial_table)
    @game.status_waiting_for_join!
    if @game.save
      render json: { table: @game.table, status: @game.status }, status: :ok
    else
      render json: { errors: @game.errors }, status: :unprocessable_entity
    end
  end

  def join_game
    return render json: 'Cannot join game, the game is complete', status: :forbidden unless @game.player2_id.nil?

    if @game.player1_id == @current_player.id || @game.player2_id == @current_player.id
      return render json: { errors: 'You cannot join the same game twice' }, status: :bad_request
    end

    @game.player2_id = @current_player.id
    @game.status_in_progress!
    if @game.save
      render json: 'Successfully joined!', status: :ok
    else
      render json: { errors: @game.errors }, status: :unprocessable_entity
    end
  end

  def show
    render json: { table: @game.table, yourTurn: check_turn }
  end

  def move
    cell_index = params.require(:cellIndex)
    # check if it is the turn of the player
    return render json: { errors: 'Its not your turn', table: @game.table }, status: :bad_request unless check_turn

    @game.moves.new(cell_index:, player_id: @current_player.id, prev_move_id: @game.moves.last&.id)

    symbol = @current_player.id == @game.player1_id ? 'x' : 'o'

    @game.table.map!.with_index { |c, i| i != cell_index ? c : symbol }
    if @game.save
      # check if player wins
      winning_combinations = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]

      player_cells = @game.moves.all.where(player_id: @current_player.id).map(&:cell_index)

      winner = winning_combinations.any? { |combination| combination.all? { |c| player_cells.include?(c) } }

      if winner
        @game.winner_id = @current_player.id
        @game.status_finished!
      end
      # check if is a tie
      a_tie = @game.table.none?(&:nil?)
      @game.status_tied! if a_tie

      render json: { table: @game.table, status: @game.status }, status: :ok
    else
      render json: { errors: @game.errors }, status: :bad_request
    end
  end

  private

  def fetch_game
    @game = Game.find(params.require(:gameId))
  end

  def can_play
    if @game.player1_id != @current_player.id && @game.player2_id != @current_player.id
      render json: { errors: 'This game is not for you!, did you try joining the game?' }, status: :forbidden
    end
  end

  def check_game_ended
    if @game.status_finished? || @game.status_tied?
      render json: { table: @game.table, status: @game.status, winner: @game.status_finished? ? Player.find_by_id(@game.winner_id).name : nil }, status: :ok

    end
  end

  def check_turn
    return false if @game.moves.empty? && @game.player1_id != @current_player.id
    return false if @game.moves.last&.player_id == @current_player.id

    true
  end
end
