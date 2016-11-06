class PagesController < ApplicationController
  def dashboard
    skip_authorization
  end
end
