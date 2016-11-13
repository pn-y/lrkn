require 'rails_helper'

RSpec.describe RouteListPolicy do
  context 'when driver' do
    let(:driver) { build :user_driver }

    subject { described_class.new(driver, nil) }

    describe '#view?' do
      it { expect(subject.view?).to eq(true) }
    end
  end

  context 'when dispatcher' do
    let(:dispatcher) { build :user }

    subject { described_class.new(dispatcher, nil) }

    describe '#view?' do
      it { expect(subject.view?).to eq(true) }
    end
  end
end
