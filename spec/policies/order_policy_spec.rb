require 'rails_helper'

RSpec.describe OrderPolicy do
  context 'when driver' do
    let(:driver) { build :user_driver }

    subject { described_class.new(driver, Order.new) }

    describe '#change?' do
      it { expect(subject.change?).to eq(false) }
    end

    describe '#view?' do
      it { expect(subject.view?).to eq(false) }
    end
  end

  context 'when dispatcher' do
    let(:dispatcher) { build :user }

    subject { described_class.new(dispatcher, Order.new) }

    describe '#change?' do
      it { expect(subject.change?).to eq(true) }
    end

    describe '#view?' do
      it { expect(subject.view?).to eq(true) }
    end
  end
end
