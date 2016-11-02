require 'rails_helper'

RSpec.describe Truck, type: :model do
  describe 'validations' do
    it { should validate_numericality_of(:max_weight) }
    it { should validate_numericality_of(:max_volume) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end
end
