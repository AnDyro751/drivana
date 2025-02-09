class Ticket < ApplicationRecord
  belongs_to :ticketable, polymorphic: true

  # Monetizar todos los campos monetarios
  monetize :daily_rate_cents
  monetize :subtotal_rent_cents
  monetize :additional_charges_cents
  monetize :discounts_cents
  monetize :taxes_cents
  monetize :total_amount_cents

  validates :issue_date, presence: true
  validates :rental_days, presence: true, numericality: { greater_than: 0 }
end
