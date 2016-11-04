require 'csv'

class CsvUploader
  class << self
    def upload(file)
      raise CsvUploaderWrongContentType if file.content_type != 'text/csv'

      Order.transaction do
        CSV.foreach(file.tempfile, headers: true, encoding: 'UTF-8').with_index do |row, index|
          create_order(row, index)
        end
      end
      [true, 'You successfully uploaded orders.']
    rescue CSV::MalformedCSVError
      [false, 'Error. Malformed CSV.']
    rescue CsvUploaderWrongContentType
      [false, 'Error. CSV file expected.']
    rescue ActiveRecord::RecordInvalid => e
      [false, "Error in row #{e.record.row_number}. #{e.message}."]
    end

    private

    def create_order(attrs, row_number)
      order = Order.new
      if attrs['delivery_date']
        order.delivery_date = Date.strptime(attrs['delivery_date'], '%m/%d/%Y')
      end
      order.delivery_shift = attrs['delivery_shift']
      order.origin_name = attrs['origin_name']
      order.origin_address = attrs['origin_raw_line_1']
      order.origin_city = attrs['origin_city']
      order.origin_state = attrs['origin_state']
      order.origin_zip = attrs['origin_zip']
      order.origin_country = attrs['origin_country']
      order.client_name = attrs['client name']
      order.destination_address = attrs['destination_raw_line_1']
      order.destination_city = attrs['destination_city']
      order.destination_state = attrs['destination_state']
      order.destination_zip = attrs['destination_zip']
      order.destination_country = attrs['destination_country']
      order.phone_number = attrs['phone_number']
      order.mode = attrs['mode']
      order.purchase_order_number = attrs['purchase_order_number']
      order.volume = attrs['volume']
      order.handling_unit_quantity = attrs['handling_unit_quantity']
      order.handling_unit_type = attrs['handling_unit_type']
      order.row_number = row_number + 1
      order.save!
    end
  end
end

class CsvUploaderWrongContentType < StandardError; end
