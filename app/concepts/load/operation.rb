class Load
  class Index < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    policy LoadPolicy, :view?

    def model!(params)
      Load.by_date_and_shift.page(params[:page])
    end
  end

  class Show < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    policy LoadPolicy, :view?

    def model!(params)
      Load.find(params[:id])
    end
  end

  class Create < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    include Model
    model Load, :create
    policy LoadPolicy, :change?

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

      collection :orders, form: Order::Contract::NestedOrder, populator: (lambda do |fragment:, **|
        return skip! if fragment['id'].blank?

        item = orders.detect { |r| r.id.to_s == fragment['id'] }

        if fragment[:_destroy] == '1'
          orders.delete(item) if item
          return skip!
        end
        item ? item : orders.append(Order.find_by(id: fragment['id']))
      end)

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
        contract.orders.each_with_index do |x, y|
          x.delivery_order = y + 1
        end
        contract.save
      end
    end
  end

  class Update < Create
    action :update
    policy LoadPolicy, :change?
  end

  class Destroy < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    include Model
    model Load, :find
    policy LoadPolicy, :change?

    def process(_)
      model.destroy
    end
  end
end
