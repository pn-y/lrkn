class AddDeliveryOrderLoadRefToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_order, :integer
    add_reference :orders, :load, index: true, foreign_key: true
  end
end
