require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_inclusion_of(:role).in_array(%w(driver dispatcher)) }

    describe 'uniqueness' do
      subject { build :user }

      it { should validate_uniqueness_of(:login).case_insensitive }
    end
  end
end
