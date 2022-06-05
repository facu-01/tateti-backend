class CreateMoves < ActiveRecord::Migration[7.0]
  def change
    create_table :moves do |t|
      t.integer :cell_index

      t.belongs_to :player
      t.belongs_to :game
      t.references :prev_move, foreign_key: { to_table: :moves }

      t.index %i[game_id cell_index], unique: true

      t.timestamps
    end
  end
end
