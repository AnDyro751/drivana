class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.references :ticketable, null: false, polymorphic: true
      t.datetime :issue_date, null: false
      t.integer :rental_days, null: false
      t.monetize :daily_rate, null: false
      t.monetize :subtotal_rent, null: false
      t.monetize :additional_charges, null: false
      t.monetize :discounts, null: false
      t.monetize :taxes, null: false
      t.monetize :total_amount, null: false

      t.timestamps
    end
  end
end
