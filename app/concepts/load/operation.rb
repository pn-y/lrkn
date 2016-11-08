class Load
  class Create < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    include Model
    model Load, :create
    policy LoadPolicy, :create?

    contract do
      include Reform::Form::ActiveModel::ModelReflections

      property :delivery_shift
      property :delivery_date
      property :truck, populator: (lambda do |model:, **|
        model
      end) do
        property :max_volume
      end
      property :truck_id, populator: (lambda do |fragment:, **|
        truck = Truck.find_by(id: fragment)
        if truck
          self.truck = truck
          self.truck_id = truck.id
        end
      end)

      collection :orders, populator: (lambda do |fragment:, **|
        return skip! if fragment['id'].blank?

        item = orders.detect { |r| r.id.to_s == fragment['id'] }

        if fragment[:_destroy] == '1'
          orders.delete(item) if item
          return skip!
        end
        item ? item : orders.append(Order.find_by(id: fragment['id']))
      end) do
        property :id, writeable: false
        property :_destroy, virtual: true

        property :destination_address
        property :volume
        property :client_name
        property :delivery_date
        property :delivery_shift

        property :destination_address
        property :destination_city
        property :destination_state
        property :destination_zip
        property :handling_unit_quantity
        property :handling_unit_type
      end

      validates :delivery_date, :delivery_shift, :truck_id, presence: true
      validates :delivery_shift, inclusion: { in: Order::DELIVERY_SHIFTS }
      validate :truck_volume
      def truck_volume
        volume = orders.map(&:volume).sum
        if truck && volume > truck.max_volume
          diff = volume - truck.max_volume
          errors.add(:truck_id,
                     "Not enough truck volume. Remove orders to free at least #{diff} cubes")
        end
      end

      validate :shift_availability
      def shift_availability
        existing_load = Load.where(delivery_date: delivery_date,
                                   delivery_shift: delivery_shift,
                                   truck_id: truck_id).
                        where.not(id: id)
        if existing_load.present?
          errors.add(:delivery_date, 'There is an existing load for this shift, date and truck')
        end
      end
    end

    def process(params)
      validate(params[:load]) do
        contract.save
      end
    end
  end

  class Update < Create
    action :update
    policy LoadPolicy, :update?
  end
end
