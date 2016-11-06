class RoutingListsController < ApplicationController
  def index
    @routing_lists = Load.by_date_and_shift.page(params[:page])
  end

  def show
    @routing_list = Load.find(params[:id])
    @waypoints = @routing_list.orders.by_deliry_order

    respond_to do |format|
      format.html
      format.pdf do
        file_name = "routing list for #{@routing_list.delivery_shift} #{@routing_list.delivery_date}"
        render pdf: file_name,
               layout: 'pdf_layout.html.slim',
               encoding: 'utf8',
               orientation: 'Landscape',
               disposition: 'attachment'
      end
    end
  end
end
