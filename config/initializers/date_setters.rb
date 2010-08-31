class ActiveRecord::Base
  def self.date_setters(*args)
    args.each do |arg|
      define_method((arg.to_s + '=').to_sym) {|value|
        if value.is_a?(String) && !value.blank?
          self[arg] = Date.strptime(value, (I18n.t 'date.formats.default'))
        else
          self[arg] = value
        end
      }
    end
  end
end