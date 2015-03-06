class Gr::NotificationsController < ApplicationController

  # Global registry will send POST requests to this endpoint
  def create
    Gr::Notification.perform_async(params[:notification])
    render nothing: true
  end
end
