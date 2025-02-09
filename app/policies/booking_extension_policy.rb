class BookingExtensionPolicy < ApplicationPolicy
  def create?
    record.booking.driver == user &&
    (record.booking.status_pending? || record.booking.status_confirmed?)
  end
end
