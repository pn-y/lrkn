require 'rails_helper'

RSpec.describe CsvUploader do
  include ActionDispatch::TestProcess

  describe '#upload' do
    subject { CsvUploader.upload(file) }

    context 'when wrong content type' do
      let(:file) { fixture_file_upload('incorrect_file.csv', 'text/xml') }

      it { is_expected.to eq([false, 'Error. CSV file expected.']) }
      it { expect { subject }.not_to change(Order, :count) }
    end

    context 'when error in CSV file' do
      let(:file) { fixture_file_upload('incorrect_file.csv', 'text/csv') }

      it do
        is_expected.to eq(
          [false,
           'Error in row 1. Validation failed: Delivery shift is not included in the list.']
        )
      end

      it { expect { subject }.not_to change(Order, :count) }
    end

    context 'when malformed CSV file' do
      let(:file) { fixture_file_upload('malformed_file.csv', 'text/csv') }

      it { is_expected.to eq([false, 'Error. Malformed CSV.']) }
      it { expect { subject }.not_to change(Order, :count) }
    end

    context 'when success' do
      let(:file) { fixture_file_upload('correct_file.csv', 'text/csv') }

      it { is_expected.to eq([true, 'You successfully uploaded orders.']) }
      it { expect { subject }.to change(Order, :count) }
    end
  end
end
