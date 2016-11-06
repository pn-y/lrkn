class LoadsController < ApplicationController
  def index
    @loads = Load.by_date_and_shift.page(params[:page])
  end

  def show
    @load = Load.find(params[:id])
  end

  def new
    @load = Load.new
  end

  def create
    @load = Load.new(load_params)
    if @load.save
      flash[:notice] = 'You successfully created load.'
      redirect_to @load
    else
      render :new
    end
  end

  def edit
    @load = Load.find(params[:id])
  end

  def update
    @load = Load.find(params[:id])
    if @load.update(load_params)
      flash[:notice] = 'Load was successfully updated.'
      redirect_to @load
    else
      render :edit
    end
  end

  def destroy
    resource = Load.find(params[:id])
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
