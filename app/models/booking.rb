class Booking < ApplicationRecord
  include DateValidatable
  include TicketableCreation

  belongs_to :car
  belongs_to :driver, class_name: "User"
  has_many :booking_extensions, dependent: :destroy
  has_many :tickets, as: :ticketable, dependent: :destroy

  monetize :total_price_cents

  enum :status, {
    pending: 0,
    confirmed: 1,
    cancelled: 2
  }, prefix: true

  validates :status, presence: true
  validates :total_price, numericality: { greater_than: 0 }
  validate :car_is_available
  validate :driver_cannot_be_car_owner
  validate :no_active_or_pending_bookings, on: :create

  before_validation :calculate_total_price, on: :create

  def cancelled!
    raise "Booking is not pending" unless status_pending?
    update!(status: :cancelled)
  end

  def confirmed!
    raise "Booking is not pending" unless status_pending?
    update!(status: :confirmed)
  end

  private

  def car_is_available
    return if car.blank?
    errors.add(:car, "no está disponible") unless car.status_available?
  end

  def driver_cannot_be_car_owner
    return if car.blank? || driver.blank?
    errors.add(:driver, "no puede reservar su propio auto") if car.user_id == driver_id
  end

  def calculate_total_price
    return if car.blank? || start_date.blank? || end_date.blank?
    rental_days = (end_date.to_date - start_date.to_date).to_i
    self.total_price = car.daily_rate * rental_days
  end

  def no_active_or_pending_bookings
    return if driver.blank?

    active_bookings = driver.bookings.where(
      status: [ :pending, :confirmed ],
      car: car
    )
    if active_bookings.exists?
      errors.add(:base, "Ya tienes una reserva activa o pendiente. No puedes crear otra hasta que finalice o canceles la actual.")
    end
  end
end
