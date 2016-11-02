class Truck < ActiveRecord::Base
  belongs_to :user

  validates :max_volume, :max_weight, numericality: true
end
