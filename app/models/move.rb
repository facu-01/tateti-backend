class Move < ApplicationRecord
  validates :game, presence: true
  validates :player, presence: true
  validates :row, numericality: { only_integer: true, in: 0..3 }
  validates :column, numericality: { only_integer: true, in: 0..3 }

  belongs_to :player
  belongs_to :game

  has_one :prev_move, required: false, class_name: 'Move'

end
