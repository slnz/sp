class Gr::NotificationsController < ApplicationController

  # Global registry will send POST requests to this endpoint
  def create
    Gr::Notification.new(params[:notification]).handle_request
    render nothing: true
  end
end
