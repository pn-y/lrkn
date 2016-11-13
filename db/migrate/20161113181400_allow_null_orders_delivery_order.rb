class AllowNullOrdersDeliveryOrder < ActiveRecord::Migration
  def change
    change_column :orders, :delivery_order, :integer, null: true
  end
end
