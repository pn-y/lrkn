require 'rails_helper'

RSpec.describe OrderCsvUploaderPolicy do
  context 'when driver' do
    let(:driver) { build :user_driver }

    subject { described_class.new(driver, nil) }

    describe '#upload?' do
      it { expect(subject.upload?).to eq(false) }
    end
  end

  context 'when dispatcher' do
    let(:dispatcher) { build :user }

    subject { described_class.new(dispatcher, nil) }

    describe '#upload?' do
      it { expect(subject.upload?).to eq(true) }
    end
  end
end
