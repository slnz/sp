class Api::V1::BaseController < ApplicationController
  before_filter :restrict_access
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  protected

  def restrict_access
    api_key = ApiKey.find_by(access_token: oauth_access_token)
    unless api_key
      render json: {error: "You either didn't pass in an access token, or the token you did pass in was wrong."},
             status: :unauthorized,
             callback: params[:callback]
      return false
    end
    @current_user = api_key.user
    true
  end

  def current_user
    @current_user || 'API'
  end

  def oauth_access_token
    @oauth_access_token ||= (params[:access_token] || oauth_access_token_from_header)
  end

  # grabs access_token from header if one is present
  def oauth_access_token_from_header
    auth_header = request.env["HTTP_AUTHORIZATION"]||""
    match = auth_header.match(/^token\s(.*)/) || auth_header.match(/^Bearer\s(.*)/)
    return match[1] if match.present?
    false
  end

  def render_404
    render nothing: true, status: 404
  end

  def add_includes_and_order(resource, options = {})
    options[:order] ||= params[:order]
    # eager loading is a waste of time if the 'since' parameter is passed
    unless params[:since]
      resource = resource.includes(available_includes) if available_includes.present?
    end
    resource = resource.where("#{resource.table.name}.updated_at > ?", Time.at(params[:since].to_i)) if params[:since].to_i > 0
    resource = resource.paginate(:page => params[:page] || 1, per_page: params[:per_page] || 100)
    resource = resource.order(options[:order]) if options[:order]
    resource
  end

  # let the api use add additional relationships to this call
  def includes
    @includes ||= params[:include].to_s.split(',')
  end

  # Each controller should override this method
  def available_includes
    []
  end

  def render_options(collection, order = nil)
    if collection.is_a?(ActiveRecord::Relation)
      collection = add_includes_and_order(collection, order: order)
    end

    res = {
      json: collection,
      callback: params[:callback],
      include: includes,
      scope: {include: includes, since: params[:since]}
    }
    if collection.respond_to?(:total_entries)
      res.merge!(meta: {total: collection.total_entries, from: collection.offset + 1,
                        to: collection.offset + collection.length, page: (params[:page] || 1).to_i})
    end
    return res
  end
end