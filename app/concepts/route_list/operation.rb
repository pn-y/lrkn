class RouteList
  class Index < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    policy RouteListPolicy, :view?

    builds -> (params) do
      return Dispatcher if params[:current_user].dispatcher?
      return Driver if params[:current_user].driver?
    end

    class Dispatcher < self
      def model!(params)
        Load.by_date_and_shift.page(params[:page])
      end
    end

    class Driver < Dispatcher
      def model!(params)
        super.seen_by_driver(params[:current_user])
      end
    end
  end

  class Show < Trailblazer::Operation
    include Trailblazer::Operation::Policy
    policy RouteListPolicy, :view?

    builds -> (params) do
      return Dispatcher if params[:current_user].dispatcher?
      return Driver if params[:current_user].driver?
    end

    class Dispatcher < self
      def model!(params)
        Load.find(params[:id])
      end
    end

    class Driver < self
      def model!(params)
        Load.seen_by_driver(params[:current_user]).find(params[:id])
      end
    end
  end
end
