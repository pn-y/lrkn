require 'rails_helper'

RSpec.describe OrderPolicy do
  subject { described_class }

  let(:dispatcher) { build :user }
  let(:driver) { build :user_driver }
  let(:order) { build :order }

  permissions :index?, :remove_from_load? do
    it { is_expected.to permit(dispatcher, order) }
    it { is_expected.not_to permit(driver, order) }
  end

  permissions :edit?, :update?, :split? do
    context 'when order not in load' do
      it { is_expected.to permit(dispatcher, order) }
      it { is_expected.not_to permit(driver, order) }
    end

    context 'when order in load' do
      before { order.load_id = 1 }

      it { is_expected.not_to permit(dispatcher, order) }
      it { is_expected.not_to permit(driver, order) }
    end
  end
end
