class ActiveRecord::Base
  def self.date_setters(*args)
    args.each do |arg|
      define_method((arg.to_s + '=').to_sym) {|value|
        if value.is_a?(String) && !value.blank?
          begin
            self[arg] = Date.strptime(value, (I18n.t 'date.formats.default'))
          rescue ArgumentError
            self[arg] = value
          end
        else
          self[arg] = value
        end
      }
    end
  end
end