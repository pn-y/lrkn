class OrderCsvUploadersController < ApplicationController
  def new
    form CsvUploader::Create
  end

  def create
    run CsvUploader::Create do
      flash[:notice] = 'Orders were successfully uploaded.'
      return redirect_to orders_url
    end

    flash[:alert] = @form.errors.full_messages.to_sentence
    render :new
  end

  private

  def process_params!(params)
    params.merge!(current_user: current_user)
  end
end
