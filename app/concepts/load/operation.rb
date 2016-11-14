class Load
  class Index < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    policy LoadPolicy, :view?

    def model!(params)
      Load.by_date_and_shift.page(params[:page])
    end
  end

  class Show < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    policy LoadPolicy, :view?

    def model!(params)
      Load.find(params[:id])
    end
  end

  class Create < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    include Model
    model Load, :create
    policy LoadPolicy, :change?

    contract Load::Contract::Create

    def process(params)
      validate(params[:load]) do
        contract.orders.each_with_index do |x, y|
          x.delivery_order = y + 1
        end
        contract.save
      end
    end
  end

  class Update < Create
    action :update
    policy LoadPolicy, :change?
  end

  class IncreaseDeliveryOrder < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    include Model
    model Load, :find
    policy LoadPolicy, :change?

    contract Load::Contract::DeliveryOrderSwap

    def process(params)
      order = get_order_with_id(params[:order_id])
      order_for_swap = get_order_with_delivery_order(order.delivery_order + 1)
      return unless order_for_swap

      order.delivery_order, order_for_swap.delivery_order = order_for_swap.delivery_order, order.delivery_order
      validate({}) do
        ActiveRecord::Base.transaction do
          order.delivery_order = -order.delivery_order
          order.save
          order_for_swap.save
          order.delivery_order = -order.delivery_order
          order.save
        end
      end
    end

    def get_order_with_id(id)
      contract.orders.detect { |x| x.id == id.to_i }
    end

    def get_order_with_delivery_order(delivery_order)
      contract.orders.detect { |x| x.delivery_order == delivery_order }
    end
  end

  class DecreaseDeliveryOrder < IncreaseDeliveryOrder
    def process(params)
      order = get_order_with_id(params[:order_id])
      order_for_swap = get_order_with_delivery_order(order.delivery_order - 1)
      return unless order_for_swap

      order.delivery_order, order_for_swap.delivery_order = order_for_swap.delivery_order, order.delivery_order
      validate({}) do
        ActiveRecord::Base.transaction do
          order_for_swap.delivery_order = -order_for_swap.delivery_order
          order_for_swap.save
          order.save
          order_for_swap.delivery_order = -order_for_swap.delivery_order
          order_for_swap.save
        end
      end
    end
  end

  class Destroy < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    include Model
    model Load, :find
    policy LoadPolicy, :change?

    def process(_)
      model.destroy
    end
  end
end
