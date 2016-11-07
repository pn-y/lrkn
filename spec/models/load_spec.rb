require 'rails_helper'

RSpec.describe Load, type: :model do
  describe 'associations' do
    it { should have_many(:orders) }
    it { should belong_to(:truck) }
  end
end
