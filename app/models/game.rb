class Game < ApplicationRecord
  validates :player1, presence: true
  validates :table, presence: true

  validates_associated :moves

  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player', optional: true

  has_many :moves

  enum status: { in_progress: 0, waiting_for_join: 1, tied: 2, finished: 3 }, _prefix: true

  # Constants
  WINNING_COMBINATIONS = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]].freeze

  # Methods

  def initialize_game(player)
    initial_table = [nil] * 9
    self.table = initial_table
    self.player1_id = player.id
    status_waiting_for_join!
  end

  def complete?
    !player1_id.nil? && !player2_id.nil?
  end

  def player_in_game?(player)
    player1_id == player.id || player2_id == player.id
  end

  def join_game(player)
    self.player2_id = player.id
    self.first_player_id = [player2_id, player1_id].sample
    status_in_progress!
  end

  def player_turn?(player)
    return false if moves.empty? && first_player_id != player.id
    return false if moves.last&.player_id == player.id

    true
  end

  def ended?
    status_finished? || status_tied?
  end

  def generate_token
    token = id * 22
    Munemo.to_s(token)
  end

  def self.read_token(token)
    token = Munemo.to_i(token)
    (token / 22)
  end

  def player_win?(player)
    player_cells = moves.all.where(player_id: player.id).map(&:cell_index)
    WINNING_COMBINATIONS.any? { |combination| combination.all? { |c| player_cells.include?(c) } }
  end

  def winning_combination
    winner = winner_player
    return nil unless winner
    cells_played = moves.select { |move| move.player.id == winner.id }.map(&:cell_index)
    WINNING_COMBINATIONS.find { |combination| (combination - cells_played).empty? }
  end

  def winner_player
    status_finished? ? Player.find_by_id(player_winner_id) : nil
  end

  def a_tie?
    table.none?(&:nil?)
  end

  def versus(player)
    nil unless complete?
    return player2 if player.id == player1_id
    player1
  end

end
