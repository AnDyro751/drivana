class Car < ApplicationRecord
  belongs_to :user

  # Configuración de Money-Rails
  monetize :daily_rate_cents, as: :daily_rate,
    numericality: {
      greater_than: 0,
      less_than: 50_000,
      message: "debe estar entre 1 y 50,000 MXN"
    }

  validates :brand, :model, :year, presence: true

  validates :brand, :model, length: { maximum: 100 }
  validates :user, presence: true

  validates :year,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1900,
      less_than_or_equal_to: -> { Time.current.year + 1 },
      message: "debe estar entre 1900 y #{Time.current.year + 1}"
    }

  validate :user_is_host

  enum :status, { available: 0, unavailable: 1 }, prefix: true

  private

  def user_is_host
    return if user.nil?
    # Solo los hosts pueden crear autos, los customers no. Ellos solo pueden reservar :(.
    errors.add(:user, "must be a host") unless user.role_host?
  end
end
