class CreateLoads < ActiveRecord::Migration
  def change
    create_table :loads do |t|
      t.date :delivery_date
      t.string :delivery_shift
      t.references :truck, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
