module Api
  class RegistrationsController < ApiController
    include RackSessionFix
    respond_to :json
    skip_before_action :authenticate_jwt_token!, only: [ :create ], raise: false
    skip_before_action :verify_authenticity_token, raise: false
    skip_before_action :authenticate_user!, only: [ :create ], raise: false

    def create
      user = User.new(sign_up_params)

      if user.save
        token = generate_jwt_token(user)
        render json: {
          status: { code: 200, message: "Se ha registrado correctamente." },
          data: UserSerializer.new(user).serializable_hash[:data][:attributes],
          token: token
        }, status: :ok
      else
        render json: {
          status: {
            code: 422,
            message: "No se ha podido registrar correctamente.",
            errors: user.errors.full_messages
          }
        }, status: :unprocessable_entity
      end
    end

    private

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :role)
    end

    def generate_jwt_token(user)
      secret = Rails.application.credentials.secret_key_base
      token = JWT.encode(
        {
          sub: user.id,
          scp: "user",
          email: user.email,
          role: user.role,
          exp: (Time.now + 1.day).to_i
        },
        secret,
        'HS256'
      )
      token
    end
  end
end
