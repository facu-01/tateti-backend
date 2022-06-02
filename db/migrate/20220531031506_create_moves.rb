class CreateMoves < ActiveRecord::Migration[7.0]
  def change
    create_table :moves do |t|
      t.integer :row
      t.integer :column

      t.belongs_to :player
      t.belongs_to :game
      t.references :prev_move, foreign_key: { to_table: :moves }

      t.timestamps
    end
  end
end
