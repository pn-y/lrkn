class OrdersController < ApplicationController
  def index
    @orders = Order.with_shift_order.page(params[:page])
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(order_params)
      flash[:notice] = 'Order was successfully updated.'
      redirect_to orders_url
    else
      render :edit
    end
  end

  def move_up
    order = Load.find(params[:load_id]).orders.find(params[:order_id])
    order.decrease_delivery_order!
    redirect_to load_url(id: params[:load_id])
  end

  def move_down
    order = Load.find(params[:load_id]).orders.find(params[:order_id])
    order.increase_delivery_order!
    redirect_to load_url(id: params[:load_id])
  end

  def split
    # TODO: dont allow split orders with load
    order = Order.find(params[:id])
    order.split!
    redirect_to orders_url
  end

  private

  def order_params
    params.require(:order).permit(
      :delivery_date,
      :delivery_shift,
      :origin_name,
      :origin_address,
      :origin_city,
      :origin_state,
      :origin_zip,
      :origin_country,
      :client_name,
      :destination_address,
      :destination_city,
      :destination_state,
      :destination_zip,
      :destination_country,
      :phone_number,
      :mode,
      :purchase_order_number,
      :volume,
      :handling_unit_quantity,
      :handling_unit_type,
      :load_id
    )
  end
end
