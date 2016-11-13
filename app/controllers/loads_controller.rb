class LoadsController < ApplicationController
  def index
    present Load::Index
    @loads = @model
  end

  def show
    present Load::Show
    @load = @model
    @waypoints = @load.orders
  end

  def new
    form Load::Create
  end

  def create
    run Load::Create do |op|
      return redirect_to op.model
    end
    render :new
  end

  def edit
    form Load::Update
  end

  def update
    run Load::Update do |op|
      return redirect_to op.model
    end
    render :edit
  end

  def destroy
    run Load::Destroy do
      flash[:notice] = 'Load was successfully deleted.'
      return redirect_to loads_url
    end

    flash[:alert] = "Load wasnt't deleted."
    redirect_to loads_url
  end

  private

  def process_params!(params)
    params.merge!(current_user: current_user)
  end
end
