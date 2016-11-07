class RouteListsController < ApplicationController
  def index
    @route_lists = policy_scope(Load).by_date_and_shift.page(params[:page])
    authorize :route_list, :index?
  end

  def show
    @route_list = policy_scope(Load).find(params[:id])
    @waypoints = @route_list.orders.by_deliry_order
    authorize :route_list, :show?

    respond_to do |format|
      format.html
      format.pdf do
        file_name = "route list for #{@route_list.delivery_shift} #{@route_list.delivery_date}"
        render pdf: file_name,
               layout: 'pdf_layout.html.slim',
               encoding: 'utf8',
               orientation: 'Landscape',
               disposition: 'attachment'
      end
    end
  end
end
