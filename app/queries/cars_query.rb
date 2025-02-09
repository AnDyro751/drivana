class CarsQuery
  def self.for_user(user)
    new(user).query
  end

  def initialize(user)
    @user = user
  end

  def query
    case @user.role
    when "host"
      @user.cars
    when "customer"
      Car.status_available
    else
      Car.none
    end
  end
end
