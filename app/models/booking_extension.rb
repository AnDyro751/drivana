class BookingExtension < ApplicationRecord
  include DateValidatable
  include TicketableCreation

  belongs_to :booking
  has_many :tickets, as: :ticketable, dependent: :destroy

  # Delegamos el driver al booking
  delegate :driver, to: :booking
  delegate :car, to: :booking

  # Aquí podríamos agregar un estado también para la extensión, pero por ahora no lo vamos a hacer
  monetize :total_price_cents

  validates :total_price, numericality: { greater_than: 0 }
  validate :start_date_after_original_booking
  validate :car_is_still_available
  validate :no_overlapping_extensions

  before_validation :calculate_total_price, on: :create

  private

  def start_date_after_original_booking
    return if start_date.blank? || booking.nil?
    if start_date < booking.end_date
      errors.add(:start_date, "debe ser después de la fecha de fin de la reservación original")
    end
  end

  def car_is_still_available
    return if booking.nil?
    errors.add(:booking, "el auto ya no está disponible") unless booking.car.status_available?
  end

  def calculate_total_price
    return if start_date.blank? || end_date.blank? || booking.nil?
    rental_days = (end_date.to_date - start_date.to_date).to_i
    self.total_price = booking.car.daily_rate * rental_days
  end

  def no_overlapping_extensions
    return if start_date.blank? || end_date.blank? || booking.nil?

    overlapping_extensions = booking.booking_extensions
      .where.not(id: id)
      .where(
        '(start_date <= ? AND end_date >= ?) OR
         (start_date <= ? AND end_date >= ?) OR
         (start_date >= ? AND end_date <= ?)',
        start_date, start_date,
        end_date, end_date,
        start_date, end_date
      )

    if overlapping_extensions.exists?
      errors.add(:base, "Ya tienes una extensión para alguna de estas fechas")
    end
  end
end
