# //TODO: validar tablero
# class TableValidator < ActiveModel::Validator
#   def validate(record)
#     record.errors.add :base, "Invalid table" if record.table.length < 3
#   end
# end

class Game < ApplicationRecord
  validates :player1, presence: true
  validates :table, presence: true

  validates_associated :moves

  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player', optional: true

  has_many :moves

  enum status: { in_progress: 0, waiting_for_join: 1, tied: 2, finished: 3 }, _prefix: true

end
