require 'rails_helper'

RSpec.describe LoadPolicy do
  context 'when driver' do
    let(:driver) { build :user_driver }

    subject { described_class.new(driver, Load.new) }

    describe '#change?' do
      it { expect(subject.change?).to eq(false) }
    end

    describe '#view?' do
      it { expect(subject.view?).to eq(false) }
    end
  end

  context 'when dispatcher' do
    let(:dispatcher) { build :user }

    subject { described_class.new(dispatcher, Load.new) }

    describe '#change?' do
      it { expect(subject.change?).to eq(true) }
    end

    describe '#destroy?' do
      it { expect(subject.view?).to eq(true) }
    end
  end
end
