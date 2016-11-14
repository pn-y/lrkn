class Order
  class Update < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    include Model
    model Order, :update
    policy OrderPolicy, :update?

    contract Contract::Update

    def process(params)
      validate(params[:order]) do
        contract.save
      end
    end
  end

  class Index < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    policy OrderPolicy, :view?

    def model!(params)
      Order.scheduled(params[:scheduled]).with_shift_order.page(params[:page])
    end
  end

  class Split < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    policy OrderPolicy, :change?

    contract Contract::Split

    def model!(params)
      Order.find(params[:id])
    end

    def process(_)
      validate(volume: contract.volume, handling_unit_quantity: contract.handling_unit_quantity) do
        model.with_lock do
          new_order = model.dup

          original_quantity = model.handling_unit_quantity
          original_volume = model.volume

          new_order.handling_unit_quantity = model.handling_unit_quantity / 2
          model.handling_unit_quantity = original_quantity - new_order.handling_unit_quantity

          new_order.volume = model.volume * new_order.handling_unit_quantity / original_quantity
          model.volume = original_volume - new_order.volume

          model.save!
          new_order.save!
        end
      end
    end
  end

  class RemoveFromLoad < Split
    policy OrderPolicy, :change?

    contract Contract::RemoveFromLoad

    def process(_)
      validate(load_id: contract.load_id) do
        model.update(load_id: nil)
      end
    end
  end

  class DecreaseDeliveryOrder < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    policy OrderPolicy, :change?

    def model!(params)
      Load.find(params[:load_id]).orders.find(params[:order_id])
    end

    def process(_)
      second_order = order_for_swap
      return if second_order.nil?
      swap_delivery_order(model, second_order)
    end

    private

    def order_for_swap
      Order.where('load_id = ? and delivery_order < ?', model.load_id, model.delivery_order).
        order(delivery_order: :DESC).limit(1).first
    end

    def swap_delivery_order(first_order, second_order)
      model.transaction do
        second_order_delivery_order = second_order.delivery_order

        second_order.update!(delivery_order: -second_order_delivery_order)

        second_order.delivery_order = first_order.delivery_order
        first_order.delivery_order = second_order_delivery_order
        first_order.save!
        second_order.save!
      end
    end
  end

  class IncreaseDeliveryOrder < DecreaseDeliveryOrder
    policy OrderPolicy, :change?

    def order_for_swap
      Order.where('load_id = ? and delivery_order > ?', model.load_id, model.delivery_order).
        order(delivery_order: :ASC).limit(1).first
    end
  end
end
