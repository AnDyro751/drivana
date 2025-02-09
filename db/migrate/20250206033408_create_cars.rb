class CreateCars < ActiveRecord::Migration[8.0]
  def change
    create_table :cars do |t|
      t.string :brand, null: false
      t.references :user, null: false, foreign_key: true
      t.string :model, null: false
      t.string :year, null: false
      t.integer :status, null: false, default: 0
      t.monetize :daily_rate, as: :daily_rate, currency: { present: true, default: "MXN" }
      t.timestamps
    end
  end
end
