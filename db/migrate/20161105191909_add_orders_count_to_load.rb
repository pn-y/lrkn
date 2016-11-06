class AddOrdersCountToLoad < ActiveRecord::Migration
  def change
    add_column :loads, :orders_count, :integer, default: 0, null: false
  end
end
