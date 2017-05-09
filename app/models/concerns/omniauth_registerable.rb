module OmniauthRegisterable
  extend ActiveSupport::Concern

  module ClassMethods
    def find_for_oauth(auth, user = nil)
      # Get the identity and user if they exist
      user = User.where(uid: auth.uid, provider: auth.provider).first

      # Create the user if needed
      user ||= find_or_create_user_for_oauth(auth)
      user
    end

    private
      def find_or_create_user_for_oauth(auth)
        user_params = provider_service(auth.provider).new(auth).user_params
        user = User.find_by(email: user_params[:email]) if user_params[:email]
        user || create_user_for_oauth!(auth, user_params)
      end

      def create_user_for_oauth!(auth, parameters)
        user = User.new(parameters)
        user.password = SecureRandom.hex(32) # so we don't need to tweak validations
        user.skip_confirmation! # because the oauth provider has already supposedly validated the email
        user.save!
        user
      end

      def provider_service(provider)
        if provider
          "#{ provider.classify }ProviderService".constantize
        end
      end
  end
end
