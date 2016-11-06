class Order < ActiveRecord::Base
  attr_accessor :row_number

  DELIVERY_SHIFTS = %w(M N E).freeze

  belongs_to :load, counter_cache: true

  validates :delivery_shift, inclusion: { in: DELIVERY_SHIFTS }, allow_nil: true
  validates :delivery_order, uniqueness: { scope: :load_id },
                             if: 'delivery_order.present? && load_id.present?'

  scope :with_shift_order, (lambda do
    order('coalesce(delivery_date) ASC NULLS FIRST',
          "(case delivery_shift when 'E' then 0 when 'N' then 1 when 'M' then 2 else -1 end) DESC")
  end)

  scope :by_deliry_order, -> { order('delivery_order ASC NULLS LAST') }

  def split!
    return if handling_unit_quantity <= 1
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

  def decrease_delivery_order_in_load!
    return if load_id.nil?
    order_for_swap =
      Order.where('load_id = ? and delivery_order < ?', load_id, delivery_order).
      order(delivery_order: :DESC).limit(1).first
    return if order_for_swap.nil?
    Order.swap_delivery_order(self, order_for_swap)
  end

  def increase_delivery_order_in_load!
    return if load_id.nil?
    order_for_swap =
      Order.where('load_id = ? and delivery_order > ?', load_id, delivery_order).
      order(delivery_order: :ASC).limit(1).first
    return if order_for_swap.nil?
    Order.swap_delivery_order(self, order_for_swap)
  end

  def self.swap_delivery_order(first_order, second_order)
    transaction do
      second_order_delivery_order = second_order.delivery_order

      second_order.update!(delivery_order: -second_order_delivery_order)

      second_order.delivery_order = first_order.delivery_order
      first_order.delivery_order = second_order_delivery_order
      first_order.save!
      second_order.save!
    end
  end
end
