class BookingPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.driver == user
  end

  def new?
    return false if user.nil?
    return false if record.car.nil?
    return false if record.nil?
    return false if has_active_or_pending_bookings?
    record.car.user != user
  end

  def create?
    new?
  end

  def cancel?
    record.driver == user && (record.status_pending? || record.status_confirmed?)
  end

  def extend?
    record.driver == user && (record.status_pending? || record.status_confirmed?)
  end

  def ticket?
    record.driver == user
  end

  private

  def has_active_or_pending_bookings?
    user.bookings.where(car: record.car, status: [ :pending, :confirmed ]).exists?
  end
end
