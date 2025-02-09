class CreateBookingExtensions < ActiveRecord::Migration[8.0]
  def change
    create_table :booking_extensions do |t|
      t.references :booking, null: false, foreign_key: true
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.monetize :total_price, null: false

      t.timestamps
    end
  end
end
