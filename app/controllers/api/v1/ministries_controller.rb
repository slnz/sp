class Api::V1::MinistriesController < Api::V1::BaseController

  def index
    ministries = MinistryFilter.new(params[:filters]).filter(Ministry.all)
    render render_options(ministries, params[:order] || 'name')
  end

  def show
    ministry = Ministry.find(params[:id])
    render render_options(ministry)
  end

end