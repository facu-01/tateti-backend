# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :fetch_game, only: %i[join_game show move]
  before_action :fetch_player, only: %i[create join_game show move]
  before_action :can_play, only: %i[show move]
  before_action :check_game_ended, only: %i[move show]

  def index
    @games = Game.all
    get_response(message: 'All games', data: @games)
  end

  def create
    initial_table = [nil, nil, nil, nil, nil, nil, nil, nil, nil]
    @game = Game.new(player1_id: @player.id, table: initial_table)
    @game.status_waiting_for_join!
    if @game.save
      get_response(message: 'Game created successfully', data: { gameId: @game.id })
    else
      get_response(message: @game.errors, status: 400)
    end
  end

  def join_game
    return get_response(message: 'Cannot join game, the game is complete ', status: 400) unless @game.player2_id.nil?
    if @game.player1_id == @player.id || @game.player2_id == @player.id
      return get_response(message: 'You cannot join the same game twice', status: 400)
    end

    @game.player2_id = @player.id
    @game.status_in_progress!
    if @game.save
      get_response(message: 'Successfully joined')
    else
      get_response(message: @game.errors, status: 400)
    end
  end

  def show
    if check_turn
      get_response(message: 'Its your turn', data: { table: @game.table, yourTurn: true })
    else
      get_response(message: 'Its not your turn', data: { table: @game.table, yourTurn: false })
    end
  end

  def move
    cell_index = params.require(:cellIndex)
    # check if it is the turn of the player
    return get_response(message: 'Its not your turn', data: { table: @game.table }, status: 400) unless check_turn

    @game.moves.new(cell_index:, player_id: @player.id, prev_move_id: @game.moves.last&.id)

    symbol = @player.id == @game.player1_id ? 'x' : 'o'

    @game.table.map!.with_index { |c, i| i != cell_index ? c : symbol }
    if @game.save
      # check if player wins
      winning_combinations = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]

      player_cells = @game.moves.all.where(player_id: @player.id).map(&:cell_index)

      winner = winning_combinations.any? { |combination| combination.all? { |c| player_cells.include?(c) } }

      if winner
        @game.winner_id = @player.id
        @game.status_finished!
        return get_response(message: 'You win!', data: { table: @game.table })
      end

      # check if is a tie
      a_tie = @game.table.none?(&:nil?)

      if a_tie
        @game.status_tied!
        return get_response(message: 'Its a tie!', data: { table: @game.table })
      end

      get_response(message: 'Nice move!', data: { table: @game.table })
    else
      get_response(message: @game.errors, status: 400)
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

  def check_game_ended
    if @game.status_finished?
      get_response(message: "The game has ended, you #{@game.winner_id == @player.id ? 'win!' : 'lost :('}",
                   data: { table: @game.table })
    end
    get_response(message: 'The game has ended its a tie!', data: { table: @game.table }) if @game.status_tied?

  end

  def check_turn
    return false if @game.moves.empty? && @game.player1_id != @player.id
    return false if @game.moves.last&.player_id == @player.id

    true
  end
end
