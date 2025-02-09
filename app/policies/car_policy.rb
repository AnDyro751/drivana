class CarPolicy < ApplicationPolicy
  include DashboardHelper

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.role_host?
  end

  def update?
    user.role_host? && record.user == user
  end

  def destroy?
    user.role_host? && record.user == user
  end

  def reserve?
    # Un cliente no puede reservar un auto que no esté disponible
    return false unless record.status_available?
    # Un cliente no puede reservar su propio auto
    return false if record.user == user
    # Un cliente no puede reservar un auto que ya tenga una reserva activa
    return false if user_has_active_booking?(record, user)
    true
  end

  class Scope < Scope
    def resolve
      if user.role_host?
        # Los hosts solo ven sus propios carros
        scope.where(user: user)
      else
        # Los customers ven todos los carros disponibles
        scope.where(status: :available)
      end
    end
  end
end
