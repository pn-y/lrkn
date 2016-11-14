require 'rails_helper'

RSpec.describe CsvUploader, type: :operation do
  include ActionDispatch::TestProcess

  let(:user) { create :user }
  let(:params) { { csv_file: file, current_user: user } }

  subject { described_class::Create.call(params) }

  describe 'validations' do
    context 'when wrong content type' do
      let(:file) { fixture_file_upload('incorrect_file.csv', 'text/xml') }

      it do
        expect { subject }.
          to raise_exception(Trailblazer::Operation::InvalidContract, /CSV file expected./)
      end
    end

    context 'when error in CSV file' do
      let(:file) { fixture_file_upload('incorrect_file.csv', 'text/csv') }

      it do
        expect { subject }.to raise_exception(
          Trailblazer::Operation::InvalidContract,
          /"Row 1, delivery shift is not included in the list", "Row 4, delivery shift is not included in the list"/
        )
      end
    end

    context 'when malformed CSV file' do
      let(:file) { fixture_file_upload('malformed_file.csv', 'text/csv') }

      it do
        expect { subject }.
          to raise_exception(Trailblazer::Operation::InvalidContract, /Malformed CSV./)
      end
    end
  end

  describe '::Create' do
    context 'when success' do
      let(:file) { fixture_file_upload('correct_file.csv', 'text/csv') }

      it { expect { subject }.to change(Order, :count).by(3) }

      it 'correctly recognize returning orders' do
        subject
        expect(Order.where(returning: true).count).to eq(1)
      end
    end
  end
end
