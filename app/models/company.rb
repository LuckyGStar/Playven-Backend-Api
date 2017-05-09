class Company < ActiveRecord::Base
  has_many :admins, dependent: :destroy
  has_many :venues, dependent: :destroy
  has_many :users, through: :venues
  has_many :reservations, through: :venues
  has_many :game_passes, through: :venues
  has_many :courts, through: :venues
  has_many :invoices, dependent: :destroy
  serialize :stripe_account_status, JSON

  # Stripe::BalanceTransaction.all({:transfer => "tr_17yKSgBavI8QpPIoLEJe4Zut"}, {:stripe_account => self.stripe_user_id})

  def user_reservations(user)
    reservations.where(user: user).order(start_time: :asc)
  end

  def connected?; !stripe_user_id.nil?; end

  def managed?; stripe_account_type == 'managed'; end

  def manager
    case stripe_account_type
    when 'managed' then StripeManaged.new(self)
    end
  end

  def can_accept_charges
    return true if managed? && stripe_account_status['charges_enabled']
    return false
  end

  def transfers(start_date, end_date)
    Stripe::Transfer.all({:date => {gte:(DateTime.parse(start_date)).to_i, lte:(DateTime.parse(end_date)).to_i}},{stripe_account: self.stripe_user_id})
  end

  def transfer_transactions(transfer)
    Stripe::BalanceTransaction.all({:transfer => transfer}, {:stripe_account => self.stripe_user_id})
  end

  def trans_hist(grouping)
    Stripe::BalanceTransaction.all(self.filter(grouping), {stripe_account: self.stripe_user_id})
  end

  def balance
    Stripe::Balance.retrieve({stripe_account: self.stripe_user_id}).pending[0].amount / 100
  end

  def charges_data(grouping)
    data = self.charges(grouping)
    amount = 0
    data.each do |d|
      amount += d.amount
    end

    {
      count: data.count,
      amount: amount/100
    }
  end

  def charges(grouping)
    Stripe::Charge.all(self.filter(grouping),
    {stripe_account: self.stripe_user_id}).data
  end

  def customers
    customers = []
    User.all.each do |user|
      companies = user.reservations.map do |resv|
        resv.court.venue.company
      end
      customers << user unless not companies.include? self
    end
    return customers
  end

  def user_outstanding_balance(user)
    invoicable_reservations = reservations.where(user: user).invoicable
    invoicable_game_passes = game_passes.where(user: user).invoicable

    invoicable_reservations.map(&:outstanding_balance).sum.to_f +
      invoicable_game_passes.map(&:price).sum.to_f
  end

  def outstanding_balances
    invoicable_reservations = reservations.invoicable.group_by(&:user_id)
    invoicable_game_passes = game_passes.invoicable.group_by(&:user_id)

    user_ids = invoicable_reservations.keys + invoicable_game_passes.keys

    user_ids.map do |user_id|
      [user_id,
        invoicable_reservations[user_id].try(:map, &:outstanding_balance).try(:sum).to_f +
        invoicable_game_passes[user_id].try(:map, &:price).try(:sum).to_f
      ]
    end.to_h
  end

  def filter(grouping)
    case
    when grouping == 'day'
      {
        created: {
          gte: Time.now.beginning_of_day.to_i,
          lt: Date.tomorrow.beginning_of_day.to_i
        }
      }
    when grouping == 'month'
      {
        created: {
          gte: Time.now.beginning_of_month.to_i,
          lt: Time.now.beginning_of_month.next_month.to_i
        }
      }
    when grouping == 'year'
      {
        created: {
          gte: Time.now.beginning_of_year.to_i,
          lt: Time.now.beginning_of_year.next_year.to_i
        }
      }
    end
  end

  def has_stripe?
    stripe_user_id != nil
  end

  def last_god?(admin)
    !admins.any? { |a| a != admin && a.role?('god') }
  end

  # return VAT decimal based on company_business_type
  # decimal = percentage / 100
  # TODO use enum for company_business_type
  def get_vat_decimal
    case company_business_type
    when 'Rekisteröity yhdistys'
      BigDecimal.new('0')
    else
      BigDecimal.new('0.10')   # 10 %
    end
  end
end
