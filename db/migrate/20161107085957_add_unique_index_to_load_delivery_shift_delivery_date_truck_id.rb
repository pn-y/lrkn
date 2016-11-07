class AddUniqueIndexToLoadDeliveryShiftDeliveryDateTruckId < ActiveRecord::Migration
  def change
    add_index :loads, [:delivery_shift, :delivery_date, :truck_id], unique: true
  end
end
