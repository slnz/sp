module CruEnhancements
  extend ActiveSupport::Concern

  included do |c|
    if defined?(c::INCLUDES)
      has_many *c::INCLUDES

    end
  end

  def attributes
    hash = super
    hash.delete_if {|k, v| v.blank?}
    hash
  end

end
