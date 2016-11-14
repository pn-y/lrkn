class AddReturnToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :returning, :boolean, null: false, default: false
  end
end
