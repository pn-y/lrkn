class Order < ActiveRecord::Base
  DELIVERY_SHIFTS = %w(M N E).freeze

  belongs_to :load, counter_cache: true

  scope :with_shift_order, (lambda do
    order('coalesce(delivery_date) ASC NULLS FIRST',
          "(case delivery_shift when 'E' then 0 when 'N' then 1 when 'M' then 2 else -1 end) DESC",
          'destination_address')
  end)

  scope :scheduled, (lambda do |value|
    if value == 'true'
      where.not(load_id: nil)
    elsif value == 'false'
      undelivered
    end
  end)

  scope :undelivered, -> { where(load_id: nil) }

  scope :by_deliry_order, -> { order('delivery_order ASC NULLS LAST') }
end
