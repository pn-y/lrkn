class AddSequenceToOrderDeliveryOrder < ActiveRecord::Migration
  def up
    change_column :orders, :delivery_order, :integer, null: false
    execute <<-SQL
      CREATE SEQUENCE order_delivery_order_seq START 1;
      ALTER SEQUENCE order_delivery_order_seq OWNED BY orders.delivery_order;
      ALTER TABLE orders ALTER COLUMN delivery_order SET DEFAULT nextval('order_delivery_order_seq');
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE order_delivery_order_seq CASCADE;
    SQL
  end
end
