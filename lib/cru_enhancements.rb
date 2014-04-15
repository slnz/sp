module CruEnhancements
  extend ActiveSupport::Concern

  included do |c|
    if defined?(c::INCLUDES)
      has_many *c::INCLUDES

      c::INCLUDES.each do |relationship|
        define_method(relationship) do
          add_since(object.send(relationship))
        end
      end
    end
  end

  def add_since(rel)
    if scope.is_a?(Hash) && scope[:since].to_i > 0
      rel.where("#{rel.table.name}.updated_at > ?", Time.at(scope[:since].to_i))
    else
      rel
    end
  end

  def include_associations!
    includes = scope[:include] if scope.is_a? Hash
    if includes && defined?(self.class::INCLUDES)
      includes.each do |rel|
        include!(rel.to_sym) if self.class::INCLUDES.include?(rel.to_sym)
      end
    else
      super
    end
  end

  def attributes
    hash = super
    hash.delete_if {|k, v| v.blank?}
    hash
  end

end