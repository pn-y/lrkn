class OrderCsvUploadersController < ApplicationController
  def new
    authorize :order_csv_uploader, :new?
  end

  def create
    authorize :order_csv_uploader, :create?

    result, message = CsvUploader.upload(params[:csv_file])
    if result
      flash[:notice] = message
      redirect_to orders_url
    else
      flash[:error] = message
      render :new
    end
  end
end
