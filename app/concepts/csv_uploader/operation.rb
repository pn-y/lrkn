require 'csv'

class CsvUploader
  class Create < Trailblazer::Operation
    contract do
      include Reform::Form::ActiveModel::ModelReflections

      property :csv_file, virtual: true
      collection :orders, form: Order::Contract::UploadFromCsv,
                          virtual: true,
                          default: [],
                          populate_if_empty: Order

      validates :csv_file, presence: true
      validate :file_content_type, if: 'csv_file.present?'
      def file_content_type
        errors.add(:base, 'CSV file expected.') if csv_file.content_type != 'text/csv'
      end

      validate :file_content, if: 'csv_file.present?'
      def file_content
        CSV.read(csv_file.tempfile, headers: true, encoding: 'UTF-8')
      rescue CSV::MalformedCSVError, ArgumentError
        errors.add(:base, 'Malformed CSV.')
      end
    end

    def process(params)
      validate(params) do
        orders_arr = []
        CSV.foreach(contract.csv_file.tempfile,
                    headers: true,
                    encoding: 'UTF-8').with_index do |row, index|
          orders_arr << order_attrs(row, index)
        end

        validate(params.merge(orders: orders_arr)) do
          contract.orders.map(&:save)
        end
      end
    end

    private

    def order_attrs(csv_row, row_number)
      order_attrs = {}
      if csv_row['delivery_date']
        order_attrs[:delivery_date] = Date.strptime(csv_row['delivery_date'], '%m/%d/%Y')
      end
      order_attrs[:delivery_shift] = csv_row['delivery_shift']
      order_attrs[:origin_name] = csv_row['origin_name']
      order_attrs[:origin_address] = csv_row['origin_raw_line_1']
      order_attrs[:origin_city] = csv_row['origin_city']
      order_attrs[:origin_state] = csv_row['origin_state']
      order_attrs[:origin_zip] = csv_row['origin_zip']
      order_attrs[:origin_country] = csv_row['origin_country']
      order_attrs[:client_name] = csv_row['client name']
      order_attrs[:destination_address] = csv_row['destination_raw_line_1']
      order_attrs[:destination_city] = csv_row['destination_city']
      order_attrs[:destination_state] = csv_row['destination_state']
      order_attrs[:destination_zip] = csv_row['destination_zip']
      order_attrs[:destination_country] = csv_row['destination_country']
      order_attrs[:phone_number] = csv_row['phone_number']
      order_attrs[:mode] = csv_row['mode']
      order_attrs[:purchase_order_number] = csv_row['purchase_order_number']
      order_attrs[:volume] = csv_row['volume']
      order_attrs[:handling_unit_quantity] = csv_row['handling_unit_quantity']
      order_attrs[:handling_unit_type] = csv_row['handling_unit_type']
      order_attrs[:row_number] = row_number + 1
      order_attrs
    end
  end
end
