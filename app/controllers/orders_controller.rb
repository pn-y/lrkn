class OrdersController < ApplicationController
  def index
    present Order::Index
    @orders = @model
  end

  def edit
    form Order::Update
  end

  def update
    run Order::Update do
      flash[:notice] = 'Order was successfully updated.'
      return redirect_to orders_url
    end

    render :edit
  end

  def split
    run Order::Split do
      flash[:notice] = 'Order was successfully splitted.'
      return redirect_to orders_url
    end

    flash[:alert] = "Order cannot be splitted. #{@form.errors.full_messages.to_sentence}"
    redirect_to orders_url
  end

  def remove_from_load
    run Order::RemoveFromLoad do
      flash[:notice] = 'Order was successfully removed from the Load.'
      return redirect_to orders_url
    end

    flash[:alert] = 'Order not in the Load.'
    redirect_to orders_url
  end

  def move_up
    operation = Load::DecreaseDeliveryOrder.run(id: params[:load_id],
                                                order_id: params[:order_id],
                                                current_user: current_user) do
      return redirect_to load_url(id: params[:load_id])
    end
    flash[:alert] = "Delivery order was not changed. #{operation.errors.full_messages.to_sentence}"
    redirect_to load_url(id: params[:load_id])
  end

  def move_down
    operation = Load::IncreaseDeliveryOrder.run(id: params[:load_id],
                                                order_id: params[:order_id],
                                                current_user: current_user) do
      return redirect_to load_url(id: params[:load_id])
    end
    flash[:alert] = "Delivery order was not changed. #{operation.errors.full_messages.to_sentence}"
    redirect_to load_url(id: params[:load_id])
  end

  private

  def process_params!(params)
    params.merge!(current_user: current_user)
  end
end
