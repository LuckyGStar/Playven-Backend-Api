class API::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def facebook
    register_user(:facebook)
  end

  def failure
    render json: { errors: [env['omniauth.error'].message] }, status: :unprocessable_entity
  end

  private

  def register_user(provider)
    user = User.find_for_oauth(omniauth_auth_params_with_extra, current_user)
    access_token, expiry = AuthToken.encode(id: user.id)
    if user.persisted?
      render json: {auth_token: AuthToken.encode(JSON.parse(user.to_json))}
    else
      warden.custom_failure!
      render json: { errors: user.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def omniauth_auth_params_with_extra
    omniauth_auth_params.merge(omniauth_extra_params)
  end

  def omniauth_auth_params
    request.env['omniauth.auth'] || {}
  end

  def omniauth_extra_params
    request.env['omniauth.params'] || {}
  end

end
