class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.json :table

      t.belongs_to :player1
      t.belongs_to :player2

      t.timestamps
    end
  end
end
