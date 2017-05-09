class OmniauthProviderService
  attr_reader :auth

  def initialize(auth)
    @auth = auth
  end

  def user_params
    {
      first_name: first_name,
      last_name: last_name,
      email: email,
      country: country,
      city: city,
      locale: locale
    }.compact
  end

  def provider
    self.class.name.sub(/ProviderService/, '').underscore.to_sym
  end

  private
    def auth_raw_info
      auth.extra.raw_info
    end

    def locale
      auth_raw_info.locale
    end

    def email
      auth.info.email
    end

    def address_parser
      @address_parser ||= AddressParser.new(auth_raw_info.location.try(:name))
    end

    def country
      address_parser.country
    end

    def city
      address_parser.city
    end
end
