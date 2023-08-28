class AddExpiresAtToPurchases < ActiveRecord::Migration[7.0]
  def change
    add_column :purchases, :expires_at, :datetime 
  end
end
