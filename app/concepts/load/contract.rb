class Load
  module Contract
    module LoadProperties
      include Reform::Form::Module

      property :delivery_shift
      property :delivery_date
      property :truck, populator: (lambda do |model:, **|
        model
      end) do
        property :max_volume
      end
      property :truck_id, populator: (lambda do |fragment:, **|
        truck = Truck.find_by(id: fragment)
        if truck
          self.truck = truck
          self.truck_id = truck.id
        end
      end)

      collection :orders, form: Order::Contract::NestedOrder, populator: (lambda do |fragment:, **|
        return skip! if fragment['id'].blank?

        item = orders.detect { |r| r.id.to_s == fragment['id'].to_s }

        if fragment[:_destroy] == '1'
          orders.delete(item) if item
          return skip!
        end
        item ? item : orders.append(Order.find_by(id: fragment['id']))
      end)

      validate :truck_volume
      def truck_volume
        simple_volume_validation(orders.select(&:returning).sum(&:volume), ' returning')
        volume_loaded = orders.select { |x| !x.returning }.sum(&:volume)
        simple_volume_validation(volume_loaded)
        if truck
          free_space_left = truck.max_volume - volume_loaded
          complex_volume_validation(get_delivery_order_ret_orders, free_space_left)
        end
      end

      def get_delivery_order_ret_orders
        orders.select(&:returning).inject([]) { |acc, n| acc << orders.index(n) + 1 }
      end

      def simple_volume_validation(volume, type = nil)
        if truck && volume > truck.max_volume
          diff = volume - truck.max_volume
          errors.add(:truck_id,
                     "Not enough truck volume. Remove#{type} orders to free at least #{diff} cubes")
        end
      end

      def complex_volume_validation(delivery_orders, free_space)
        delivery_orders.each do |delivery_order|
          sliced = sorted_orders.slice(0, delivery_order - 1)
          unloaded = sliced.select { |x| !x.returning }.sum(&:volume)
          loaded = sliced.select(&:returning).sum(&:volume)
          if unloaded + free_space - loaded < sorted_orders[delivery_order - 1].volume
            errors.add(:truck_id,
                       "will have not enough volume after #{delivery_order.ordinalize} waypoint")
          end
        end
      end

      def sorted_orders
        orders
      end
    end

    class Create < Reform::Form
      include Reform::Form::ActiveModel::ModelReflections
      include LoadProperties

      validates :delivery_date, :delivery_shift, :truck_id, presence: true
      validates :delivery_shift, inclusion: { in: Order::DELIVERY_SHIFTS }
      validate :shift_availability
      def shift_availability
        existing_load = Load.where(delivery_date: delivery_date,
                                   delivery_shift: delivery_shift,
                                   truck_id: truck_id).
                        where.not(id: id)
        if existing_load.present?
          errors.add(:delivery_date, 'There is an existing load for this shift, date and truck')
        end
      end
    end

    class DeliveryOrderSwap < Reform::Form
      include LoadProperties

      def get_delivery_order_ret_orders
        orders.select(&:returning).map(&:delivery_order)
      end

      def sorted_orders
        orders.sort_by(&:delivery_order)
      end
    end
  end
end
