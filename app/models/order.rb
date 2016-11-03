class Order < ActiveRecord::Base
  attr_accessor :row_number

  DELIVERY_SHIFTS = %w(M N E).freeze

  validates :delivery_shift, inclusion: { in: DELIVERY_SHIFTS }, allow_nil: true
end
