class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :car, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: { to_table: :users }
      t.monetize :total_price, null: false
      t.integer :status, default: 0, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false

      t.timestamps
    end
  end
end
