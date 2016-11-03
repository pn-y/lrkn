require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it { should validate_inclusion_of(:delivery_shift).in_array(%w(E N M)).allow_nil }
  end
end
