module Api
  class SessionsController < ApiController
    include RackSessionFix

    skip_before_action :authenticate_user!, only: [ :create ], raise: false
    skip_before_action :verify_signed_out_user, raise: false
    skip_before_action :verify_authenticity_token, raise: false

    respond_to :json

    def create
      user = User.find_by(email: sign_in_params[:email])

      if user && user.valid_password?(sign_in_params[:password])
        sign_in(user)
        token = generate_jwt_token(user)
        render json: {
          status: { code: 200, message: "Sesión iniciada correctamente." },
          data: UserSerializer.new(user).serializable_hash[:data][:attributes],
          token: token
        }, status: :ok
      else
        render json: {
          status: { code: 401, message: "Email o contraseña inválidos." }
        }, status: :unauthorized
      end
    rescue => e
      Rails.logger.error "Login error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: {
        status: { code: 400, message: "Error en la solicitud" },
        error: e.message
      }, status: :bad_request
    end

    def destroy
      sign_out(current_user)
      render json: {
        status: { code: 200, message: "Sesión cerrada correctamente." }
      }, status: :ok
    end

    private

    def sign_in_params
      params.require(:session).permit(:email, :password)
    end

    def generate_jwt_token(user)
      JWT.encode(
        {
          sub: user.id,
          scp: "user",
          email: user.email,
          role: user.role,
          jti: user.jti,
          exp: (Time.now + 1.day).to_i
        },
        Rails.application.credentials.secret_key_base,
        'HS256'
      )
    end
  end
end
