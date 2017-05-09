class AddressParser
  ADDRESS_SEPARATOR = ', '.freeze

  attr_reader :city, :country

  def initialize(address_string)
    @address_string = address_string || ''
    parse
  end

  private
    def parse
      @city    = address_parts.to(-2).join(ADDRESS_SEPARATOR).presence
      @country = address_parts.last
    end

    def address_parts
      @address_parts ||= @address_string.split(ADDRESS_SEPARATOR)
    end
end
