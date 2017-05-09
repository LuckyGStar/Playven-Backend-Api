class FacebookProviderService < OmniauthProviderService
  private
    def first_name
      auth_raw_info['first_name']
    end

    def last_name
      auth_raw_info['last_name']
    end

    def email_verified?
      auth.info.verified || auth.info.verified_email
    end

    def photo_url
      auth.info.image.presence
    end
end
