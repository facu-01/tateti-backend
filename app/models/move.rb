class Move < ApplicationRecord
  validates :game, presence: true
  validates :player, presence: true
  validates :cell_index,
            numericality: { only_integer: true, in: 0..8,
                            message: 'Invalid move the cell index must be a number and in range of [0..9]' }

  validates :cell_index, uniqueness: { scope: :game_id, message: 'Invalid move, that cell has already been occupied' }

  belongs_to :player
  belongs_to :game

  has_one :prev_move, required: false, class_name: 'Move'

end
