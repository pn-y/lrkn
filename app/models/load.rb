class Load < ActiveRecord::Base
  belongs_to :truck

  has_many :orders, -> { order(delivery_order: :ASC) }, dependent: :nullify

  scope :seen_by_driver, ->(driver) { joins(:truck).where(trucks: { user_id: driver.id }) }

  scope :by_date_and_shift, (lambda do
    order('delivery_date DESC',
          "(case delivery_shift when 'E' then 0 when 'N' then 1 when 'M' then 2 end) ASC")
  end)
end
