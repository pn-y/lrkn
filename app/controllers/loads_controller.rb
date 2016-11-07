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
    trb_preparing
    form Load::Create
  end

  def create
    trb_preparing
    run Load::Create do |op|
      return redirect_to op.model
    end
    render :new
  end

  def edit
    trb_preparing
    form Load::Update
  end

  def update
    trb_preparing
    run Load::Update do |op|
      return redirect_to op.model
    end
    render :edit
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

  def trb_preparing
    skip_authorization
    params.merge!(current_user: current_user)
  end
end
