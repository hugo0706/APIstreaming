class AddUniqueIndexToPurchases < ActiveRecord::Migration[7.0]
  def change
    add_index :purchases, [:purchase_option_id, :purchasable_id, :purchasable_type, :user_id], unique: true, name: 'unique_purchase_constraint'
  end
end
