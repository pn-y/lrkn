require 'rails_helper'

RSpec.describe Load, type: :model do
  describe 'associations' do
    it { should have_many(:orders).order(delivery_order: :ASC) }
    it { should belong_to(:truck) }
  end

  describe 'scopes' do
    describe '.by_date_and_shift' do
      subject { described_class.by_date_and_shift }

      let(:load_e) { create :load, delivery_shift: 'E', delivery_date: '02.11.2015' }
      let(:load_m) { create :load, delivery_shift: 'M', delivery_date: '02.11.2015' }
      let(:load_n) { create :load, delivery_shift: 'N', delivery_date: '02.11.2015' }
      let(:older_load_m) { create :load, delivery_shift: 'M', delivery_date: '01.11.2015' }
      let(:newer_load_m) { create :load, delivery_shift: 'N', delivery_date: '03.11.2015' }

      it do
        expect(subject).to eq([newer_load_m, load_e, load_n, load_m, older_load_m])
      end
    end

    describe '.seen_by_driver' do
      let(:truck) { create :truck }
      let(:driver) { create :user_driver, truck: truck }
      let(:first_load) { create :load, truck_id: truck.id }
      let(:second_load) { create :load, delivery_shift: 'N', truck_id: truck.id }
      let(:third_load) { create :load, delivery_shift: 'M' }

      subject { described_class.seen_by_driver(driver) }

      it { is_expected.to match_array([first_load, second_load]) }
    end
  end
end
