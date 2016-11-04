class Order < ActiveRecord::Base
  attr_accessor :row_number

  DELIVERY_SHIFTS = %w(M N E).freeze

  validates :delivery_shift, inclusion: { in: DELIVERY_SHIFTS }, allow_nil: true

  scope :with_shift_order, (lambda do
    order("coalesce(delivery_date) ASC NULLS FIRST",
          "(case delivery_shift when 'E' then 0 when 'N' then 1 when 'M' then 2 else -1 end) DESC")
  end)

  def split!
    return if handling_unit_quantity == 1
    with_lock do
      new_order = dup

      original_quantity = handling_unit_quantity
      original_volume = volume

      new_order.handling_unit_quantity = handling_unit_quantity / 2
      self.handling_unit_quantity = original_quantity - new_order.handling_unit_quantity

      new_order.volume = volume * new_order.handling_unit_quantity / original_quantity
      self.volume = original_volume - new_order.volume

      save!
      new_order.save!
    end
  end
end
