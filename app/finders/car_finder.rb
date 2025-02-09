class CarFinder
  def self.find_for_user(user:, id:)
    new(user).find(id)
  end

  def initialize(user)
    @user = user
  end

  def find(id)
    case @user.role
    when "host"
      @user.cars.find(id)
    when "customer"
      Car.find(id)
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
