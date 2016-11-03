require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_inclusion_of(:role).in_array(%w(driver dispatcher)) }

    describe 'uniqueness' do
      subject { build :user }

      it { should validate_uniqueness_of(:login).case_insensitive }
    end
  end

  describe 'associations' do
    it { should have_one(:truck) }
  end

  describe 'role predicates' do
    context 'when dispatcher' do
      subject { build :user }

      it { is_expected.to be_dispatcher }
      it { is_expected.not_to be_driver }
    end

    context 'when driver' do
      subject { build :user_driver }

      it { is_expected.not_to be_dispatcher }
      it { is_expected.to be_driver }
    end
  end
end
