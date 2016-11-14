class Order
  module Contract
    module OrderProperties
      include Reform::Form::Module
      property :delivery_date
      property :delivery_shift
      property :origin_name
      property :origin_address
      property :origin_city
      property :origin_state
      property :origin_zip
      property :origin_country
      property :client_name
      property :destination_address
      property :destination_city
      property :destination_state
      property :destination_zip
      property :destination_country
      property :phone_number
      property :mode
      property :purchase_order_number
      property :volume
      property :handling_unit_quantity
      property :handling_unit_type
      property :delivery_order
      property :returning
    end

    class Update < Reform::Form
      include Reform::Form::ActiveModel::ModelReflections
      include OrderProperties

      def client_name=(value)
        self.returning = value == 'Larkin LLC'
        super(value)
      end

      validates :volume, numericality: { less_than: 100_000, greater_than_or_equal_to: 0 },
                         allow_nil: true
      validates :delivery_shift, inclusion: { in: Order::DELIVERY_SHIFTS }, allow_nil: true
    end

    class NestedOrder < Update
      property :_destroy, virtual: true
    end

    class UploadFromCsv < Reform::Form
      include OrderProperties
      property :row_number, virtual: true

      validate :volume_numericality
      def volume_numericality
        vol = volume.to_f
        return if volume.blank? || (vol >= 0 && vol < 100_000)
        errors.add(
          :base,
          "Row #{row_number}, volume must be greater than or equal to 0 and less than 100000"
        )
      end

      validate :delivery_shift_inclusion
      def delivery_shift_inclusion
        return if delivery_shift.blank? || Order::DELIVERY_SHIFTS.include?(delivery_shift)
        errors.add(:base, "Row #{row_number}, delivery shift is not included in the list")
      end
    end

    class Split < Reform::Form
      property :handling_unit_quantity
      property :volume
      property :load_id

      validates :volume, numericality: { greater_than_or_equal_to: 1 }
      validates :handling_unit_quantity, numericality: { greater_than: 1 }
      validates :load_id, absence: true
    end

    class RemoveFromLoad < Reform::Form
      property :load_id

      validates :load_id, presence: true
    end
  end
end
