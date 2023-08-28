class CreatePurchaseOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_options do |t|
      t.references :optionable, polymorphic: true, null: false
      t.decimal :price, precision: 5, scale: 2
      t.string :quality

      t.timestamps
    end
  end
end
