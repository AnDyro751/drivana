class ApiController < ApplicationController
  include Pundit::Authorization
  include Devise::Controllers::Helpers

  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_json_format

  rescue_from JWT::DecodeError do |_|
    render json: {
      status: { code: 401, message: "Token inválido o expirado." }
    }, status: :unauthorized
  end

  rescue_from JWT::ExpiredSignature do |_|
    render json: {
      status: { code: 401, message: "El token ha expirado." }
    }, status: :unauthorized
  end

  rescue_from Pundit::NotAuthorizedError do |_|
    render json: {
      status: { code: 403, message: "No tienes permiso para realizar esta acción." }
    }, status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do |_|
    render json: {
      status: { code: 404, message: "Recurso no encontrado." }
    }, status: :not_found
  end

  private

  def set_json_format
    request.format = :json
  end

  def respond_with_error(message, status = :unprocessable_entity)
    render json: {
      status: { code: Rack::Utils::SYMBOL_TO_STATUS_CODE[status], message: message }
    }, status: status
  end

  def respond_with_success(message, status = :ok)
    render json: {
      status: { code: Rack::Utils::SYMBOL_TO_STATUS_CODE[status], message: message }
    }, status: status
  end

  def authenticate_user!
    if request.headers["Authorization"].present?
      token = request.headers["Authorization"].split(" ").last
      begin
        puts token
        secret = Rails.application.credentials.secret_key_base
        puts secret
        decoded_token = JWT.decode(
          token, 
          secret, 
          true, 
          { algorithm: 'HS256' }
        )
        puts decoded_token.inspect
        user_id = decoded_token.first["sub"]
        user = User.find_by(id: user_id)
        
        if user
          sign_in(user)
        else
          render json: {
            status: { code: 401, message: "Usuario no encontrado." }
          }, status: :unauthorized
        end
      rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
        Rails.logger.error("Error de autenticación JWT: #{e.message}")
        render json: {
          status: { code: 401, message: "Token inválido o expirado." }
        }, status: :unauthorized
      end
    else
      render json: {
        status: { code: 401, message: "Necesitas iniciar sesión o registrarte para continuar." }
      }, status: :unauthorized
    end
  end
end
