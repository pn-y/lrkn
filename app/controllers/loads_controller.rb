class LoadsController < ApplicationController
  def index
    @loads = policy_scope(Load).by_date_and_shift.page(params[:page])
    authorize @loads
  end

  def show
    @load = Load.find(params[:id])
    @waypoints = @load.orders.by_deliry_order
    authorize @load
  end

  def new
    @load = Load.new
    authorize @load
  end

  def create
    @load = Load.new(load_params)
    authorize @load
    if @load.save
      flash[:notice] = 'You successfully created load.'
      redirect_to @load
    else
      render :new
    end
  end

  def edit
    @load = Load.find(params[:id])
    authorize @load
  end

  def update
    @load = Load.find(params[:id])
    authorize @load
    if @load.update(load_params)
      flash[:notice] = 'Load was successfully updated.'
      redirect_to @load
    else
      render :edit
    end
  end

  def destroy
    resource = Load.find(params[:id])
    authorize resource
    resource.destroy
    if request.referer
      redirect_to :back
    else
      redirect_to loads_url
    end
  end

  private

  def load_params
    params.require(:load).permit(:delivery_shift, :delivery_date, :truck_id)
  end
end
