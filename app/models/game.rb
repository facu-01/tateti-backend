class Game < ApplicationRecord
  validates :player1, presence: true
  validates :table, presence: true

  validates_associated :moves

  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player', optional: true

  has_many :moves

  enum status: { in_progress: 0, waiting_for_join: 1, tied: 2, finished: 3 }, _prefix: true

  def initialize_game(current_player)
    initial_table = [nil] * 9
    self.table = initial_table
    self.player1_id = current_player.id
    self.status_waiting_for_join!
  end

  def complete?
    !self.player1_id.nil? && !self.player2_id.nil?
  end

  def player_in_game?(current_player)
    self.player1_id == current_player.id || self.player2_id == current_player.id
  end

  def join_game(current_player)
    self.player2_id = current_player.id
    self.first_player_id = [self.player2_id, self.player1_id].sample
    self.status_in_progress!
  end

  def player_turn?(current_player)
    return false if self.moves.empty? && self.first_player_id != current_player.id
    return false if self.moves.last&.player_id == current_player.id

    true
  end

  def game_ended?
    self.status_finished? || self.status_tied?
  end

  def winning_combination
    self.table
  end

  def generate_token
    token = self.id * 22
    Munemo.to_s(token)
  end

  def self.read_token(token)
    token = Munemo.to_i(token)
    (token / 22)
  end

end
