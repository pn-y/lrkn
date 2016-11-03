class Order < ActiveRecord::Base

  DELIVERY_SHIFTS = %w(M N E).freeze

  validates :delivery_shift, inclusion: { in: DELIVERY_SHIFTS }, allow_nil: true
end
