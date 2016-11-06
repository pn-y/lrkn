class Load < ActiveRecord::Base
  belongs_to :truck

  has_many :orders, dependent: :nullify

  validates :delivery_shift, presence: true,
                             inclusion: { in: Order::DELIVERY_SHIFTS },
                             uniqueness: { scope: :delivery_date }
  validates :delivery_date, :truck_id, presence: true

  scope :by_date_and_shift, (lambda do
    order('delivery_date DESC',
          "(case delivery_shift when 'E' then 0 when 'N' then 1 when 'M' then 2 end) ASC")
  end)
end
