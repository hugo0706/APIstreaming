class AddUniqueIndexToEpisodes < ActiveRecord::Migration[7.0]
  def change
    add_index :episodes, [:number, :season_id], unique: true
  end
end
