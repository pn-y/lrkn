class CreateTrucks < ActiveRecord::Migration
  def change
    create_table :trucks do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :max_weight
      t.integer :max_volume
    end
  end
end
