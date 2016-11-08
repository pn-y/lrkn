require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the OrdersHelper. For example:
#
# describe OrdersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe OrdersHelper, type: :helper do
  describe '#order_label_for_load' do
    subject { order_label_for_load(order) }

    context 'when returning order' do
      let(:order) { create :order }

      it do
        is_expected.to eq('2016-11-01, E 627 GARFIELD DRIVE, FORT BRAGG, NC, 283047, box, 15.53')
      end
    end

    context 'when not returning order' do
      let(:order) { create :order_returning }

      it { is_expected.to eq('2016-11-01, E 1505 S BLOUNT ST, RALEIGH, NC, 276037, box, 15.53') }
    end
  end

  describe '#route_list_address_string' do
    subject { route_list_address_string(order) }

    context 'when returning order' do
      let(:order) { create :order }

      it do
        is_expected.to eq('627 GARFIELD DRIVE, FORT BRAGG, NC, 28304')
      end
    end

    context 'when not returning order' do
      let(:order) { create :order_returning }

      it { is_expected.to eq('1505 S BLOUNT ST, RALEIGH, NC, 27603') }
    end
  end

  describe '#order_row_style' do
    subject { order_row_style(order) }

    context 'loaded order' do
      let(:order) { create :order, load: (create :load) }

      it { is_expected.to eq('info') }
    end

    context 'danger order' do
      let(:order) { create :order, delivery_date: nil }

      it { is_expected.to eq('danger') }
    end

    context 'order for return' do
      let(:order) { create :order_returning }

      it { is_expected.to eq('warning') }
    end
  end
end
