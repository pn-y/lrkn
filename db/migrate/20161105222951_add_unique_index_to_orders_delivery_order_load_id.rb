class AddUniqueIndexToOrdersDeliveryOrderLoadId < ActiveRecord::Migration
  def change
    add_index :orders,
              [:delivery_order, :load_id],
              unique: true,
              where: 'load_id is not null and delivery_order is not null'
  end
end
