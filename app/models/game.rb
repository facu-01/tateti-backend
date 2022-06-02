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
  validates_associated :player1
  validates_associated :player2

  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player', optional: true

  has_many :moves

end
