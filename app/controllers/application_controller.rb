class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
    def partners
      @partners ||= begin
        @partners = Region.where("region <> ''").collect(&:region)
        @partners += Ministry.all.collect(&:name)
      end
    end
    helper_method :partners
end
