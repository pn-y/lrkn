class RouteListsController < ApplicationController
  def index
    present RouteList::Index
    @route_lists = @model
  end

  def show
    present RouteList::Show
    @route_list = @model
    @waypoints = @route_list.orders

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

  private

  def process_params!(params)
    params.merge!(current_user: current_user)
  end
end
