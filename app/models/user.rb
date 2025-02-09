class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist
  has_many :bookings, foreign_key: :driver_id, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum :role, { customer: 0, host: 1 }, prefix: true

  validates :role, presence: true

  has_many :cars, dependent: :destroy

  before_create :set_jti

  def jwt_payload
    {
      "role" => role,
      "email" => email
    }
  end

  private

  def set_jti
    self.jti = SecureRandom.uuid
  end
end
